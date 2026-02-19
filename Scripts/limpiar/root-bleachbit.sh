#!/bin/bash

xhost si:localuser:root
sudo bleachbit
xhost -si:localuser:root
