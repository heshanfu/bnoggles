// Copyright (c) 2018, The Bnoggles Team.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import '../../dictionary.dart';
import 'clean_dict_file.dart';

void main(List<String> arguments) async {
  var result = await processAff();
  print(result);
}

Future<List<Map<String, Set<Affix>>>> processAff() async {
  List<String> contents = await readFile();

  var interpreter = _AffixInterpreter(contents.iterator);
  interpreter.process();

  return [interpreter._prefixes, interpreter._suffixes];
}

Future<List<String>> readFile() async {
  var input = File('tools/lang/en/assets/index.aff');
  var contents = await input.readAsLines();
  return contents;
}

class _AffixInterpreter {
  _AffixInterpreter(this._lines);

  final Iterator<String> _lines;

  final Map<String, Set<Affix>> _prefixes = Map();
  final Map<String, Set<Affix>> _suffixes = Map();

  void process() {
    while (_lines.moveNext()) {
      route(_lines.current);
    }
  }

  void route(String current) {
    String line = current.trim();
    if (line.isEmpty) {
      return;
    }

    if (line.startsWith("#")) {
      return;
    }

    if (line.startsWith("PFX ")) {
      return startPrefix(line);
    }

    if (line.startsWith("SFX ")) {
      return startSuffix(line);
    }

    throw FormatException("cannot parse line '$current'");
  }

  List<String> splitLine(String line) {
    String singleSpaces = line.trim();
    while (singleSpaces.contains("  ")) {
      singleSpaces = singleSpaces.replaceAll("  ", " ");
    }

    return singleSpaces.split(" ");
  }

  Map<String, dynamic> parseHeader(String line) {
    var elements = splitLine(line);
    assert(elements.length == 4, "unexpected format in header '$line'");

    var type = elements[0];
    var name = elements[1];
    var combineYN = elements[2];

    try {
      int length = int.parse(elements[3]);
      assert(length > 0, "unexpected number of lines to follow '$line'");

      return <String, dynamic>{
        "type": type,
        "combineable": (combineYN == 'Y'),
        "name": name,
        "linesToFollow": length
      };
    } on Exception catch (_) {
      print("error parsing '$line'");
      rethrow;
    }
  }

  void parseAffixLines(
      String header,
      void affixAdder(bool combinable, String name, int toRemove, String toAdd,
          SuffixCondition condition)) {
    var headerInfo = parseHeader(header);

    for (int i = 0; i < (headerInfo["linesToFollow"] as int); i++) {
      assert(_lines.moveNext(), "not enough lines below header '$header'");
      var elements = splitLine(_lines.current);
      assert(elements[0] == headerInfo["type"],
          "unexpected line header '$header', line ${_lines.current}");
      var name = elements[1];
      assert(name == headerInfo["name"],
          "unexpected line header '$header', line ${_lines.current}");

      var toRemove = createRemoveLength(elements[2]);
      var toAdd = clean(stripContinuation(elements[3]));

      if (toAdd.isNotEmpty) {
        affixAdder(headerInfo["combineable"] as bool, name, toRemove, toAdd,
            createCondition(elements));
      }
    }
  }

  int createRemoveLength(String element) =>
      (element == "0") ? 0 : element.length;

  SuffixCondition createCondition(List<String> elements) {
    var pattern = elements.length >= 5 ? clean(elements[4]) : "";
    if (pattern == ".") {
      return emptyCondition;
    }

    return SuffixCondition(pattern);
  }

  String stripContinuation(String toAdd) => toAdd.split("/")[0];

  void startPrefix(String header) {
    void prefixAdder(bool combinable, String name, int toRemove, String toAdd,
        SuffixCondition condition) {
      assert(toRemove == 0, "expected 0 for remove option in prefix");
      assert(condition == emptyCondition,
          'expected no condition for prefix. $condition');

      _prefixes.putIfAbsent(name, () => Set()).add(Prefix(combinable, toAdd));
    }

    parseAffixLines(header, prefixAdder);
  }

  void startSuffix(String header) {
    void suffixAdder(bool combinable, String name, int toRemove, String toAdd,
        SuffixCondition condition) {
      _suffixes
          .putIfAbsent(name, () => Set())
          .add(Suffix(combinable, toAdd, toRemove, condition));
    }

    parseAffixLines(header, suffixAdder);
  }
}
