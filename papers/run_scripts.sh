#!/usr/bin/env bash
chmod +x papers/scripts/*.sh

cd papers/
./scripts/install-extensions.sh
./scripts/update-extensions.sh

sudo ./scripts/install-fonts.sh