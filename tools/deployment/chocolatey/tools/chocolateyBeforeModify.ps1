#  Copyright (c) 2014-present, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under both the Apache 2.0 license (found in the
#  LICENSE file in the root directory of this source tree) and the GPLv2 (found
#  in the COPYING file in the root directory of this source tree).
#  You may select, at your option, one of the above-listed licenses.

#Requires -Version 3.0

. "$PSScriptRoot\\osquery_utils.ps1"

# Ensure the service is stopped and processes are not running if exists.
if ((Get-Service $serviceName -ErrorAction SilentlyContinue) -and `
  (Get-Service $serviceName).Status -eq 'Running') {
  Stop-Service $serviceName
  # If we find zombie processes, ensure they're termintated
  $proc = Get-Process | Where-Object { $_.ProcessName -eq 'osqueryd' }
  if ($null -ne $proc) {
    Stop-Process -Force $proc -ErrorAction SilentlyContinue
  }
}

# Lastly, ensure that the Deny Write ACLs have been removed before modifying
if (Test-Path $daemonFolder) {
  Set-DenyWriteAcl $daemonFolder 'Remove'
}
if (Test-Path $extensionsFolder) {
  Set-DenyWriteAcl $extensionsFolder 'Remove'
}
