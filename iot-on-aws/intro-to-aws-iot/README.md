# Introducttion to AWS Internet of Things (IoT)

Commands used in the lab

```bash
cd simulator

# Create certificate, public and private key for iot
aws iot create-keys-and-certificate --set-as-active \
--certificate-pem-outfile certs/certificate.pem \
--public-key-outfile certs/public.key \
--private-key-outfile certs/private.key
```

- Create a thing type (call HomeAutomation)
- Create a thing (called Thermostat, Searchable attribute HomeAutomation (Created above) with Value Bedroom)
- For shadow statement for the time use statment below

```bash
{
  "state": {
    "desired": {
      "airConditioningIsOn": false
    },
    "reported": {
      "airConditioningIsOn": false
    }
  }
}
```

- Certificate and Policy already created (Policy was create at lab startup, and certificate create with script above)
- Attach policy and thing to the certificate
- Create SNS Topic (ThermostatNotification, Display name: Thermostat)
- Create IOT Rule (Rule name: EmailRule, use the use sql statement below for description and rule query or annything you like, SNS target SNS topic above, Message Format: RAW, Choose iot-role )
# Rule query statement

```bash
SELECT * FROM 'house' WHERE temperature > 60 AND temperature < 80
```

Run the simulator

```bash
# Setup npm and run the simulator
npm config set registry http://registry.npmjs.org/
npm install
node simulator.js
```

After running the simulator for some time, edit the device shadow statement (classic shadow) for the thing with the shadow statement below

```bash
{
  "state": {
    "desired": {
      "airConditioningIsOn": true
    }
  }
}
```
