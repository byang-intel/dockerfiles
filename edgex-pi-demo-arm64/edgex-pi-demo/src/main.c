/* template implementation of an Edgex device service using C SDK */

/*
 * Copyright (c) 2018
 * IoTech Ltd
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 */

#include "edgex/devsdk.h"

#include <assert.h>
#include <unistd.h>
#include <signal.h>
#include <sys/time.h>
#include "mraa/gpio.h"

#define ERR_CHECK(x) if (x.code) { fprintf (stderr, "Error: %d: %s\n", x.code, x.reason); return x.code; }

typedef struct template_driver
{
  iot_logging_client * lc;
  bool state_flag;
  pthread_mutex_t mutex;
  edgex_device_service *svc;

  mraa_gpio_context gpio_devs[41]; /* pi3 */
} template_driver;


static sig_atomic_t running = true;
static void inthandler (int i)
{
  running = (i != SIGINT);
}


/* --- Initialize ---- */
/* Initialize performs protocol-specific initialization for the device
 * service.
 */
static bool template_init
(
  void *impl,
  struct iot_logging_client *lc,
  const edgex_nvpairs *config
)
{
  template_driver *driver = (template_driver *) impl;
  lc=iot_log_default;
  driver->lc = lc;
  driver->state_flag=false;
  pthread_mutex_init (&driver->mutex, NULL);
  memset(driver->gpio_devs, 0, sizeof(driver->gpio_devs));
  mraa_init();
  iot_log_debug(driver->lc,"Init");
  return true;
}

/* ---- Discovery ---- */
/* Device services which are capable of device discovery should implement it
 * in this callback. It is called in response to a request on the
 * device service's discovery REST endpoint. New devices should be added using
 * the edgex_device_add_device() method
 */
static void template_discover (void *impl) {}

/* ---- Get ---- */
/* Get triggers an asynchronous protocol specific GET operation.
 * The device to query is specified by the addressable devaddr. nreadings is
 * the number of values being requested and defines the size of the requests
 * and readings arrays. For each value, the commandrequest holds information
 * as to what is being requested. The implementation of this method should
 * query the device accordingly and write the resulting value into the
 * commandresult.
 *
 * Note - In a commandrequest, the DeviceObject represents a deviceResource
 * which is defined in the device profile.
*/
static bool template_get_handler
(
  void *impl,
  const edgex_addressable *devaddr,
  uint32_t nreadings,
  const edgex_device_commandrequest *requests,
  edgex_device_commandresult *readings
)
{
  char *interface = NULL;
  int pins[4];
  int pin_num = 0;
  template_driver *driver = (template_driver *) impl;

  /* Access the address of the device to be accessed and log it */
  iot_log_info(driver->lc, "GET on address: %s",devaddr->address);
  for (uint32_t i = 0; i < nreadings; i++)
  {
    edgex_nvpairs * current = requests->devobj->attributes;
    while (current!=NULL)
    {
      if (strcmp (current->name, "Interface") ==0) {
        interface = current->value;
      }
      if (strcmp (current->name, "Pin_Num") ==0) {
        pin_num = sscanf(current->value, "%d,%d,%d,%d", pins, pins + 1, pins + 2, pins + 3);
      }
      current = current->next;
    }

    if (strcmp (interface, "GPIO") ==0) {
      int val;
      int pin = pins[0];
      assert (pin_num == 1 && pin > 0 && pin < sizeof(driver->gpio_devs)/sizeof(driver->gpio_devs[0]));
      pthread_mutex_lock (&driver->mutex);
      if (driver->gpio_devs[pin] == NULL) {
        driver->gpio_devs[pin] = mraa_gpio_init_raw(pin);
        assert(driver->gpio_devs[pin] != NULL);
        mraa_gpio_dir(driver->gpio_devs[pin], MRAA_GPIO_IN);
      }
      pthread_mutex_unlock (&driver->mutex);
      val = mraa_gpio_read(driver->gpio_devs[pin]);
      readings[i].type = Bool;
      readings[i].value.bool_result = val ? 1 : 0;
      iot_log_info(driver->lc, "GPIO: read pin[%d] = %d", pin, val);
    }

    if (strcmp (interface, "Sensor-Dist") ==0) {
      struct  timeval start, end, tv_tmp;
      unsigned long long diff_us;
      float distance_cm;
      int pin_trig = pins[0];
      int pin_echo = pins[1];
      assert (pin_num == 2
          && pin_trig > 0 && pin_trig < sizeof(driver->gpio_devs)/sizeof(driver->gpio_devs[0])
          && pin_echo > 0 && pin_echo < sizeof(driver->gpio_devs)/sizeof(driver->gpio_devs[0]));
      pthread_mutex_lock (&driver->mutex);
      if (driver->gpio_devs[pin_trig] == NULL) {
        driver->gpio_devs[pin_trig] = mraa_gpio_init_raw(pin_trig);
        assert(driver->gpio_devs[pin_trig] != NULL);
        mraa_gpio_dir(driver->gpio_devs[pin_trig], MRAA_GPIO_OUT);
      }
      if (driver->gpio_devs[pin_echo] == NULL) {
        driver->gpio_devs[pin_echo] = mraa_gpio_init_raw(pin_echo);
        assert(driver->gpio_devs[pin_echo] != NULL);
        mraa_gpio_dir(driver->gpio_devs[pin_echo], MRAA_GPIO_IN);
      }

      mraa_gpio_write(driver->gpio_devs[pin_trig], 1);
      usleep(10);
      mraa_gpio_write(driver->gpio_devs[pin_trig], 0);

      gettimeofday(&tv_tmp,NULL);
      while(1) {
        gettimeofday(&start,NULL);
        if (mraa_gpio_read(driver->gpio_devs[pin_echo]) == 1)
          break;
        diff_us = 1000000 * (start.tv_sec - tv_tmp.tv_sec) + start.tv_usec - tv_tmp.tv_usec;
        if (diff_us > 100000)
          break;
      }
      gettimeofday(&tv_tmp,NULL);
      while(1) {
        gettimeofday(&end,NULL);
        if (mraa_gpio_read(driver->gpio_devs[pin_echo]) == 0)
          break;
        diff_us = 1000000 * (end.tv_sec - tv_tmp.tv_sec) + end.tv_usec - tv_tmp.tv_usec;
        if (diff_us > 100000)
          break;
      }

      diff_us = 1000000 * (end.tv_sec - start.tv_sec) + end.tv_usec - start.tv_usec;
      distance_cm = diff_us/58.82; /* (t * 340 m/s) / 2 */

      iot_log_info(driver->lc, "diff us: %lld, distance: %fcm\n", diff_us, distance_cm);
      readings[i].type = Int32;
      readings[i].value.i32_result = (int)distance_cm;
      pthread_mutex_unlock (&driver->mutex);
    }
  }
  return true;
}

/* ---- Put ---- */
/* Put triggers an asynchronous protocol specific SET operation.
 * The device to set values on is specified by the addressable devaddr.
 * nvalues is the number of values to be set and defines the size of the
 * requests and values arrays. For each value, the commandresult holds the
 * value, and the commandrequest holds information as to where it is to be
 * written. The implementation of this method should effect the write to the
 * device.
 *
 * Note - In a commandrequest, the DeviceObject represents a deviceResource
 * which is defined in the device profile.
*/
static bool template_put_handler
(
  void *impl,
  const edgex_addressable *devaddr,
  uint32_t nvalues,
  const edgex_device_commandrequest *requests,
  const edgex_device_commandresult *values
)
{
  char *interface = NULL;
  int pins[4];
  int pin_num = 0;
  template_driver *driver = (template_driver *) impl;

  /* Access the address of the device to be accessed and log it */
  iot_log_debug(driver->lc, "PUT on address: %s",devaddr->address);

  for (uint32_t i = 0; i < nvalues; i++)
  {
    edgex_nvpairs * current = requests->devobj->attributes;
    while (current!=NULL)
    {
      iot_log_debug(driver->lc, "attr: %s = %s", current->name, current->value);
      if (strcmp (current->name, "Interface") ==0) {
        interface = current->value;
      }
      if (strcmp (current->name, "Pin_Num") ==0) {
        pin_num = sscanf(current->value, "%d,%d,%d,%d", pins, pins + 1, pins + 2, pins + 3);
	iot_log_debug(driver->lc, "pin_num=%d: pins: %d, %d, %d, %d", pin_num, pins[0], pins[1], pins[2], pins[3]);
      }
      current = current->next;
    iot_log_debug(driver->lc, "current: %p", current);
    }
    if (strcmp (interface, "GPIO") ==0) {
      int pin = pins[0];
      assert (pin_num == 1 && pin > 0 && pin < sizeof(driver->gpio_devs)/sizeof(driver->gpio_devs[0]));
      iot_log_info(driver->lc, "GPIO: write pin[%d] => %d", pin, values->value.bool_result ? 1 : 0);
      pthread_mutex_lock (&driver->mutex);
      if (driver->gpio_devs[pin] == NULL) {
        driver->gpio_devs[pin] = mraa_gpio_init_raw(pin);
        assert(driver->gpio_devs[pin] != NULL);
        mraa_gpio_dir(driver->gpio_devs[pin], MRAA_GPIO_OUT);
      }
      pthread_mutex_unlock (&driver->mutex);
      mraa_gpio_write(driver->gpio_devs[pin], values->value.bool_result ? 1 : 0);
    }
  }
  return true;
}

/* ---- Disconnect ---- */
/* Disconnect handles protocol-specific cleanup when a device is removed. */
static bool template_disconnect (void *impl, edgex_addressable *device)
{
  return true;
}

/* ---- Stop ---- */
/* Stop performs any final actions before the device service is terminated */
static void template_stop (void *impl, bool force) {}


static void usage (void)
{
  printf ("Options: \n");
  printf ("   -h, --help           : Show this text\n");
  printf ("   -r, --registry       : Use the registry service\n");
  printf ("   -p, --profile <name> : Set the profile name\n");
  printf ("   -c, --confdir <dir>  : Set the configuration directory\n");
}

int main (int argc, char *argv[])
{
  bool useRegistry = false;
  char *profile = "";
  char *confdir = "";
  template_driver * impl = malloc (sizeof (template_driver));
  memset (impl, 0, sizeof (template_driver));

  int n = 1;
  while (n < argc)
  {
    if (strcmp (argv[n], "-h") == 0 || strcmp (argv[n], "--help") == 0)
    {
      usage ();
      return 0;
    }
    if (strcmp (argv[n], "-r") == 0 || strcmp (argv[n], "--registry") == 0)
    {
      useRegistry = true;
      n++;
      continue;
    }
    if (strcmp (argv[n], "-p") == 0 || strcmp (argv[n], "--profile") == 0)
    {
      profile = argv[n + 1];
      n += 2;
      continue;
    }
    if (strcmp (argv[n], "-c") == 0 || strcmp (argv[n], "--confdir") == 0)
    {
      confdir = argv[n + 1];
      n += 2;
      continue;
    }
    printf ("Unknown option %s\n", argv[n]);
    usage ();
    return 0;
  }

  edgex_error e;
  e.code = 0;

  /* Device Callbacks */
  edgex_device_callbacks templateImpls =
  {
    template_init,         /* Initialize */
    template_discover,     /* Discovery */
    template_get_handler,  /* Get */
    template_put_handler,  /* Put */
    template_disconnect,   /* Disconnect */
    template_stop          /* Stop */
  };

  /* Initalise a new device service */
  edgex_device_service *service = edgex_device_service_new
  (
    "Device-Grove",
    "1.0",
    impl,
    templateImpls,
    &e
  );
  ERR_CHECK (e);

  impl->svc = service;
  edgex_device_service_start
    (service, useRegistry, NULL, 0, profile, confdir, &e);
  ERR_CHECK (e);

  signal (SIGINT, inthandler);
  running = true;
  while (running)
  {
    sleep(1);
  }

  /* Stop the device service */
  edgex_device_service_stop (service, true, &e);
  ERR_CHECK (e);

  free (impl);
  exit (0);
  return 0;
}
