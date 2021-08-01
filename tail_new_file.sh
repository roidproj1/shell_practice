#!/bin/sh
ls -td1 /BACKUP/log/log_BKUP*.log | head -1 | xargs tail -f
