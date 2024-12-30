// Copyright 2024-2025 NetCracker Technology Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package utils

import (
	"bufio"
	"fmt"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
	"os"
	"os/exec"
)

var (
	logger = GetLogger()
)

type Payload struct {
	BackupId string `json:"backupId,omitempty"`
	Type     string `json:"type,omitempty"`
	Target   string `json:"target,omitempty"`
}

func ExecCommand(command string, args []string) (error, string) {
	var output string

	logger.Info(fmt.Sprintf("Executed command is %s with agrs %v", command, args))
	cmd := exec.Command(command, args...)

	stdout, err := cmd.StdoutPipe()
	if err != nil {
		logger.Error("While executing command an error occurs", zap.Error(err))
		return err, ""
	}
	if err1 := cmd.Start(); err1 != nil {
		logger.Error("While executing command an error occurs", zap.Error(err1))
		return err1, ""
	}

	in := bufio.NewScanner(stdout)

	for in.Scan() {
		output = in.Text()
		logger.Info(output)

	}
	if err2 := in.Err(); err2 != nil {
		logger.Error("error", zap.Error(err2))
		return err2, ""
	}

	return nil, output
}

func GetLogger() *zap.Logger {
	atom := zap.NewAtomicLevel()
	encoderCfg := zap.NewProductionEncoderConfig()
	encoderCfg.TimeKey = "timestamp"
	encoderCfg.EncodeTime = zapcore.ISO8601TimeEncoder

	logger := zap.New(zapcore.NewCore(
		zapcore.NewJSONEncoder(encoderCfg),
		zapcore.Lock(os.Stdout),
		atom,
	))
	defer func() { _ = logger.Sync() }()
	return logger
}
