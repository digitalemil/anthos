#!/bin/bash
cd anthos-config-management
rm -fr thegym/namespaces/tmp-thegym/
git add .
git commit -m "."
git push origin 1.0.0
cd ..
