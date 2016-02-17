#!/bin/bash

echo "{
    "\$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {" > ./testfile

a="phani1"
b="phani2"
c="phani3"
for var in a b c
do
echo $var ${!var}
done
