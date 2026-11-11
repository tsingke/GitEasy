#!/usr/bin/env python3
"""Reproduce explicit teaching changes without depending on C++ whitespace layout."""
from pathlib import Path
import argparse
import re

REFERENCE = Path(__file__).resolve().parents[1]


def marker_body(text, name):
    pattern = re.compile(r'(^[ \t]*// CAMPUS_LAB_' + name + r'_BEGIN\n)(.*?)(^[ \t]*// CAMPUS_LAB_' + name + r'_END)', re.M | re.S)
    found = list(pattern.finditer(text))
    assert len(found) == 1, (name, len(found))
    return pattern, found[0][2]


def block(target, relative, name, enabled):
    assert target.resolve() != REFERENCE, 'Use a generated teaching repository'
    path = target / relative
    original = path.read_text()
    pattern, _ = marker_body(original, name)
    _, reference = marker_body((REFERENCE / relative).read_text(), name)
    body = reference if enabled else ''
    path.write_text(pattern.sub(lambda m: m[1] + body + m[3], original))


def identity(target, enabled=True):
    if enabled:
        block(target, 'src/card_holder.cpp', 'IDENTITY', True)
    else:
        path = target / 'src/card_holder.cpp'
        pattern, _ = marker_body(path.read_text(), 'IDENTITY')
        weak = '    if (id_.empty() || name_.empty()) {\n        throw std::invalid_argument("Holder id and name are required");\n    }\n'
        path.write_text(pattern.sub(lambda m: m[1] + weak + m[3], path.read_text()))


def identity_test(target, enabled=True):
    block(target, 'tests/test_card_service.cpp', 'NAME_TEST', enabled)


def currency(target, enabled=True):
    assert target.resolve() != REFERENCE, 'Use a generated teaching repository'
    path = target / 'src/ledger_export.cpp'
    text = path.read_text()
    before, after = ('balance_after,day\\n', 'balance_after,day,currency\\n')
    old, new = ("'\\n'", '",CNY\\n"')
    if not enabled:
        before, after = after, before
        old, new = new, old
    if before in text:
        assert text.count(before) == text.count(old) == 1
        text = text.replace(before, after).replace(old, new)
    else:
        assert after in text
    path.write_text(text)
    for relative in ['tests/test_card_service.cpp', 'tests/test_ledger_export.cpp']:
        block(target, relative, 'CURRENCY', enabled)


def disable_lost_check(target):
    assert target.resolve() != REFERENCE, 'Use a generated teaching repository'
    path = target / 'src/card_service.cpp'
    text, count = re.subn(r'if\s*\(\s*target\.state\s*!=\s*CardState::Active\s*\)', 'if (false)', path.read_text())
    assert count == 1, 'Expected exactly one lost-card guard'
    path.write_text(text)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['currency', 'disable-lost-check'])
    args = parser.parse_args()
    target = Path.cwd()
    assert (target / 'BASELINE.md').exists(), 'Generate the staged teaching baseline first'
    if args.action == 'currency':
        currency(target)
    else:
        disable_lost_check(target)
