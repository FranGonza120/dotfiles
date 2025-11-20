#!/bin/bash

if command -v nextdns >/dev/null 2>&1; then
    echo "✔ nextdns ya está instalado"
else
    sh -c "$(curl -sL https://nextdns.io/install)"
fi
