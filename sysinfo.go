package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"

	"github.com/shirou/gopsutil/v3/disk"
	"github.com/shirou/gopsutil/v3/host"
	"github.com/shirou/gopsutil/v3/mem"
	// "github.com/shirou/gopsutil/mem"  // to use v2
)

func getMem() string {
	v, _ := mem.VirtualMemory()

	// almost every return value is a struct
	return fmt.Sprintf("Total %v, Available %v, Used %2.f%%", bci(v.Total), bci(v.Available), v.UsedPercent)
}

func getHostname() string {
	hostname, _ := os.Hostname()
	return hostname
}

func getDisk() string {
	hostStat, _ := host.Info()
	var diskStat *disk.UsageStat
	if hostStat.OS == "Windows" {
		diskStat, _ = disk.Usage(config.UpPath)
	} else {
		diskStat, _ = disk.Usage(config.UpPath)
	}
	return fmt.Sprintf("Total %v, Free %v, Used %2.f%%", bci(diskStat.Total), bci(diskStat.Free), diskStat.UsedPercent)
}

func getSystemInfo(w http.ResponseWriter) {
	json.NewEncoder(w).Encode(map[string]string{
		"hostname": getHostname(),
		"mem":      getMem(),
		"disk":     getDisk(),
	})
}

func bci(b uint64) string {
	const unit = 1024
	if b < unit {
		return fmt.Sprintf("%d B", b)
	}
	div, exp := int64(unit), 0
	for n := b / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.1f %ciB",
		float64(b)/float64(div), "KMGTPE"[exp])
}
