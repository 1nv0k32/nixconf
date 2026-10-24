import importlib.util
import os
import unittest
from pathlib import Path


path = Path(__file__).resolve().parents[1] / "assets" / "system-status.py"
spec = importlib.util.spec_from_file_location("system_status", path)
system_status = importlib.util.module_from_spec(spec)
spec.loader.exec_module(system_status)

GIB = 2**30


class SystemStatusTests(unittest.TestCase):
    def test_cpu_counts_iowait_as_idle(self):
        stat = "cpu  100 0 100 700 100 0 0 0 0 0\ncpu0 1 2 3 4\n"
        self.assertEqual(system_status.cpu_times(stat), (1000, 800))

    def test_cpu_percent_uses_the_delta(self):
        self.assertEqual(system_status.cpu_percent((1000, 800), (1100, 850)), 50)
        self.assertEqual(system_status.cpu_percent((1000, 800), (1000, 800)), 0)

    def test_memory_treats_available_as_free(self):
        meminfo = "MemTotal:       16777216 kB\nMemFree:  1048576 kB\nMemAvailable:   12582912 kB\n"
        self.assertEqual(system_status.memory(meminfo), (4 * GIB, 16 * GIB))

    def test_disk_matches_df_for_reserved_blocks(self):
        stat = os.statvfs_result((4096, 4096, 1000, 300, 250, 0, 0, 0, 0, 255))
        used, free = system_status.disk(stat)
        self.assertEqual((used, free), (700 * 4096, 250 * 4096))

    def test_status_tooltip_lists_every_resource(self):
        document = system_status.status(42, (4 * GIB, 16 * GIB), (300 * GIB, 100 * GIB))
        self.assertTrue(document["text"])
        self.assertEqual(
            document["tooltip"].splitlines(),
            [
                "CPU 42%",
                "RAM 4.0 / 16.0 GiB (25%)",
                "SSD 100 GiB free (75% used)",
                "Click for details",
            ],
        )


if __name__ == "__main__":
    unittest.main()
