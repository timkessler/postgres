#!/bin/bash

cat postgresql.conf | grep '^[[:blank:]]*[^[:blank:]#;]' | sort

