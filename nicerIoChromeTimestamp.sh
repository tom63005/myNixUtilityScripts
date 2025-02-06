#!/usr/bin/bash
## 
## -------------
##  Tom.Williams
##  rev-1 = re-nice the chromium-browser to less than root and user.
##  rev-2 = add the ionice command
##  rev-3 = we know the xNICE is 0, so why is the if-then not getting it?
##  rev-4 = debugger run .. errors for different BASH ver : Ubuntu -vs- Raspberry...
##  rev-5 = more debugging - root user sees CMD1,CMD2 but the pi user sees nothing in them...
##  rev-5(a) = add "license" , general code-cleanup and remove old comments
## -------------
# MIT License
#
# Copyright (c) [2025] [Tom Williams]
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
## -------------
# 
declare -i -x N nLIMIT nSLEEP nDEBUG
#
## ---
#
N=0
nSLEEP=3
nLIMIT=20
#
nDEBUG=0;  ## any non-zero is "TRUE" ..
date
#
# -x-x-x-x-x-x-
#
 # for nSLEEP = 3 ... investigation started ... 
 # nLIMIT=10 is 30-seconds,  nLIMIT=100 is (3*100)/60 = 5-minutes.
 # N=0 ; nSLEEP=3 ; nLIMIT=3 ; resulted with ( 10:54:51 AM - 10:54:39 AM ) = 12-seconds -?!
# # Jan-27-2025 ... anomoly in if-then conditional located and dealt-with // Tom.W913...
# # Jan-27-2025 ... so, if we use a $(( xyz - 1 )) in the if-then, we wind up with 61-seconds
# # Jan-27-2025 ... ?? 11:27-AM ... QA:: it seemed wo work with 9-second delay ... ?? !!!
# # Jan-27-2025 @ 11:30-AM - - re-re-evaluation ordered.
# # Feb-06-2025 @ 03:30-AM -- add MIT License , re-do some debugger comments. code clean-up.
#
# x-x-x-x-x-x-x-x-x
#
# we need to declare variables used inside the do-loop here so they are not re-declared
# over and over again, causing a run-away "malloc" like a compiled language would.
declare -i -x xPID xNICE
declare -x xCMD
# ---
while [ 1 ]; do
   # ---
   # this is the first do-loop "scope"
   # ---
   # we have local-copies of the declared variables.  Initialize them (for Debug).
   xPID=0; xNICE=44; xCMD="SOUPFORK";
   # ---
   declare -x CMD1 CMD2
   # ---
   # The USER can re-nice their own sub-processes.
   ps -u ${USER} -o "%p %n %c" | grep chrom | grep brow | grep -v grep | \
   while read xPID xNICE xCMD
   do
     # note we have created a new "scope" with the next-level do-loop
     #export xPID xNICE xCMD
     # - if we are not using them outside this "scope" then why export them ?
     # ---
     if [ ${xNICE} -lt 15 ]; then
        echo "==== 1 === Actually running command..."; date
        echo "N=${N} xPID=${xPID} xNICE=${xNICE} xCMD=${xCMD}"
        # ---
        CMD1="renice -n 15 -p ${xPID}"
        CMD2="ionice -c Best-effort -n 5 -p ${xPID}"
        ## Jan-27-2025 @ 11:55-AM == interesting, the xRC1 and xRC2 are not exported. 
        # ---
        echo "run CMD1=\"${CMD1}\""
        bash -c "${CMD1}"
        echo "completed CMD1; exit-code:" $?
        # ---
        echo "run CMD2=\"${CMD2}\""
        bash -c "${CMD2}"
        echo "completed CMD2; exit code:" $?
        # ---
        # scope level=1 is the outer do-loop
        # -  -- inside that is scope level 2, outside is scope level 0.
        # Debug info ::: 
        # - beware evil-scope wrappers...if-then. as well ?
        # - nope, the scope-problem was the do-loop within another do-loop
        #export xRC1 xRC2;   # if we do not use them outside of this scope...
        ##
        # So, now we are back to the original code with fewer "wrappers" (Feb-06-2025 05:30-AM)
        ##
     else
        if [ ${nDEBUG} -ne 0 ]; then
           echo "==== 2 === Not trying to re-nice, we already BTDT."; date
        fi
        sleep "0.02"; ## if we have an if-then *THEN MUST >> DO << **SOMETHING*** !!!  / ##
     fi
     # note that we cannot do the N=$((N+1)) here because of the "scope" level.
   done
   # as of here, the second do-loop "scope" gets destroyed
   # it contained copies of the variables from the outer-loop , plus its own variables.
   # ---
   sleep ${nSLEEP};
   N=$((${N}+1))
   if [ ${N} -ge ${nLIMIT} ]; then
       echo "==== 3 === resetting outer loop-count for sleep() # N=1 #  === "
       date
       N=1
   fi
done
