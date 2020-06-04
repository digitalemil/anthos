#!/bin/bash
cd anthos-config-management
cp -r tmp-thegym thegym/namespaces/
git add .
git commit -m "."
git push origin 1.0.0
cd ..
