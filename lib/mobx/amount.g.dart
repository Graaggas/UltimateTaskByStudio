// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'amount.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$Amount on _Amount, Store {
  final _$valueAtom = Atom(name: '_Amount.value');

  @override
  int get value {
    _$valueAtom.reportRead();
    return super.value;
  }

  @override
  set value(int value) {
    _$valueAtom.reportWrite(value, super.value, () {
      super.value = value;
    });
  }

  final _$_AmountActionController = ActionController(name: '_Amount');

  @override
  void increment() {
    final _$actionInfo =
        _$_AmountActionController.startAction(name: '_Amount.increment');
    try {
      return super.increment();
    } finally {
      _$_AmountActionController.endAction(_$actionInfo);
    }
  }

  @override
  void decrement() {
    final _$actionInfo =
        _$_AmountActionController.startAction(name: '_Amount.decrement');
    try {
      return super.decrement();
    } finally {
      _$_AmountActionController.endAction(_$actionInfo);
    }
  }

  @override
  void getStartAmount(int amount) {
    final _$actionInfo =
        _$_AmountActionController.startAction(name: '_Amount.getStartAmount');
    try {
      return super.getStartAmount(amount);
    } finally {
      _$_AmountActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
value: ${value}
    ''';
  }
}
