import 'package:mobx/mobx.dart';

part 'amount.g.dart';

class Amount = _Amount with _$Amount;

abstract class _Amount with Store{
  @observable
  int value=0;

  @action
  void increment(){
    value++;
  }

  @action
  void decrement(){
    value--;
  }

  @action
  void getStartAmount(int amount){
    value = amount;
  }
}