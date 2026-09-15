#!/usr/bin/env python3
## Copyright 2026, gRPC Authors All rights reserved.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

"""Convert LLVM's native LCOV report into SonarQube generic coverage."""

from __future__ import annotations

import argparse
import posixpath
import xml.etree.ElementTree as ET
from pathlib import Path


def clean_relative_path(path: str) -> str | None:
    """Normalize and reject coverage paths that escape the checkout."""
    normalized = posixpath.normpath(path.replace("\\", "/"))
    if normalized in ("", ".", ".."):
        return None
    if normalized.startswith("../") or normalized.startswith("/"):
        return None
    return normalized


def project_path(filename: str, source_root: Path) -> str | None:
    """Return a project-relative production source path."""
    raw_path = Path(filename.strip())
    if raw_path.is_absolute():
        try:
            source = raw_path.resolve().relative_to(source_root.resolve()).as_posix()
        except ValueError:
            return None
    else:
        source = filename.strip().replace("\\", "/")
    relative = clean_relative_path(source)
    if relative is None or not relative.startswith("Sources/"):
        return None
    return relative


def execution_lines(
    report: Path,
    source_root: Path,
    excluded_prefixes: tuple[str, ...],
) -> dict[str, dict[int, int]]:
    """Load first-party executable lines from a native LCOV report."""
    files: dict[str, dict[int, int]] = {}
    current: str | None = None
    for raw_line in report.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if line.startswith("SF:"):
            current = project_path(line[3:], source_root)
            if current is not None and current.startswith(excluded_prefixes):
                current = None
            if current is not None:
                files.setdefault(current, {})
        elif line.startswith("DA:") and current is not None:
            number_text, count_text, *_ = line[3:].split(",")
            number = int(number_text)
            count = int(count_text)
            files[current][number] = max(files[current].get(number, 0), count)
        elif line == "end_of_record":
            current = None
    return files


def write_sonar(files: dict[str, dict[int, int]], output: Path) -> None:
    """Write SonarQube generic line-coverage XML."""
    root = ET.Element("coverage", {"version": "1"})
    for filename, lines in sorted(files.items()):
        if not lines:
            continue
        file_element = ET.SubElement(root, "file", {"path": filename})
        for line, count in sorted(lines.items()):
            ET.SubElement(
                file_element,
                "lineToCover",
                {
                    "lineNumber": str(line),
                    "covered": "true" if count > 0 else "false",
                },
            )
    ET.indent(root)
    ET.ElementTree(root).write(output, encoding="utf-8", xml_declaration=True)


def main() -> int:
    """Convert one native LLVM LCOV report."""
    parser = argparse.ArgumentParser()
    parser.add_argument("report", type=Path)
    parser.add_argument("--source-root", type=Path, default=Path.cwd())
    parser.add_argument("--exclude-prefix", action="append", default=[])
    parser.add_argument("--sonar-output", type=Path, required=True)
    args = parser.parse_args()

    files = execution_lines(
        args.report,
        args.source_root,
        tuple(args.exclude_prefix),
    )
    if not files:
        parser.error("coverage report contains no first-party source files")
    write_sonar(files, args.sonar_output)
    covered = sum(count > 0 for lines in files.values() for count in lines.values())
    total = sum(len(lines) for lines in files.values())
    percentage = covered * 100.0 / total
    print(
        f"Swift first-party line coverage: {percentage:.2f}% "
        f"({covered}/{total})"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
