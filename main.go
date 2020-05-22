// Copyright 2020 Northern.tech AS
//
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
//
//        http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.

package main

import (
	"os"
    "github.com/rocaccion/android-service/pkg/android"  //@@@@
	"github.com/mendersoftware/mender/cli"
	"github.com/mendersoftware/mender/installer"
	log "github.com/sirupsen/logrus"
    "fmt"
    "io"
)

const (
	serviceName      = "mender2"      //@@@@
)

func doMain() int {
	if err := cli.SetupCLI(os.Args); err != nil {
		if err == installer.ErrorNothingToCommit {
			log.Warnln(err.Error())
			return 2
		} else {
			log.Errorln(err.Error())
			return 1
		}
	}
	return 0
}



// CopyFile copies a file from src to dst. If src and dst files exist, and are
// the same, then return success. Otherise, attempt to create a hard link
// between the two files. If that fail, copy the file contents from src to dst.
func CopyFile(src, dst string) (err error) {
    sfi, err := os.Stat(src)
    if err != nil {
        return
    }
    if !sfi.Mode().IsRegular() {
        // cannot copy non-regular files (e.g., directories,
        // symlinks, devices, etc.)
        return fmt.Errorf("CopyFile: non-regular source file %s (%q)", sfi.Name(), sfi.Mode().String())
    }
    dfi, err := os.Stat(dst)
    if err != nil {
        if !os.IsNotExist(err) {
            return
        }
    } else {
        if !(dfi.Mode().IsRegular()) {
            return fmt.Errorf("CopyFile: non-regular destination file %s (%q)", dfi.Name(), dfi.Mode().String())
        }
        if os.SameFile(sfi, dfi) {
            return
        }
    }
    if err = os.Link(src, dst); err == nil {
        return
    }
    err = copyFileContents(src, dst)
    return
}

func copyFileContents(src, dst string) (err error) {
    in, err := os.Open(src)
    if err != nil {
        return
    }
    defer in.Close()
    out, err := os.Create(dst)
    if err != nil {
        return
    }
    defer func() {
        cerr := out.Close()
        if err == nil {
            err = cerr
        }
    }()
    if _, err = io.Copy(out, in); err != nil {
        return
    }
    err = out.Sync()
    return
}



func main() {
	android.Init(serviceName)
	//fmt.Printf("Before copy\n")
    CopyFile("/system/etc/mender/mender.conf", "/data/ort/mender/mender.conf")
    CopyFile("/system/etc/mender/device_type", "/data/ort/mender/device_type")
    CopyFile("/system/etc/mender/artifact_info", "/data/ort/mender/artifact_info")     	
	//fmt.Printf("After copy\n")
/* 	if err != nil {
      fmt.Printf("CopyFile failed %q\n", err)
    } else {
      fmt.Printf("CopyFile succeeded\n")
    }
*/ 
	os.Exit(doMain())
}
