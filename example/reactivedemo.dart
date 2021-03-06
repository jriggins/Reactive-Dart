import 'dart:html';
import 'package:reactive/reactive_browser.dart';
import 'dart:isolate';
import 'dart:math';

// Demonstrates various Observable operations on sequences.

var mc = 0;
const testlist = const [1,2,3,4,5,6,7,8,9,10];

main(){

    /*
    **************************************************************************
    * Un-comment the demos that you wnat to see, rebuild, and run in browser *
    * with the browser console open.                                         *
    *                                                                        *
    * Builds with:                                                           *
    * frogc --out=reactivedemo.dart.app.js reactivedemo.dart                 *
    *                                                                        *
    * If in Dart Editor, press Alt-O to jump to any demo method.             *
    **************************************************************************
    */

    timer();
    fromEvent();

//    contains();
//    count();
//    concat();
//    fold();
//    any();
//    buffer();
//    distinct();
//    merge();
//    zip();
//    where();
//    toList();
//    timestamp();
//    apply();
//    timeout(); //adjust the timeout to see the exception throw.
//    throttle(); //Throttle has it's own demo, see '/demos/throttle_demo/throttle_demo.dart'
//    unfold();
//    range();
    fromXMLHttpRequest();
//    take();
//    takeWhile();
//    first();
//    single();
//    returnValue();
//    throwE();
//    random();
//    firstOf();
//    sample();
//    skip();
//    skipWhile();
//    pace();
//    fromFuture();
//    animationFrame();
}


// How sequence diagrams work.
//**************************************************************************************
//
// Sequence diagrams provide a visual representation of an observable's behavioral
// characteristics.
//
// - Each horizontal line represents a sequence, and each sequence is numbered 1 - n
// - The lines represent relative linear time moving from left to right.
// - Each element emitted by a sequence is represented by the sequence's number.
// Symbol Key:
// - =  A unit of time.
// X = Exceptions
// # = Termination of Sequence
// f = Between lines represents some function applied.
// S = The sequence emitted to the .observe() method.
//
// Example 1 - Single observable which throws an error.
// 1|--X---->
//  |  |
// S|--X
//
// Example 2 - Two observable sequences which merge and terminate at different times.
// 1|--1--------1------1------#
//  |  |        |      |      |
// 2|----2---2------#  |      |
//  |  | |   |  |      |      |
// S|--1-2---2--1------1------#
//
//**************************************************************************************

void animationFrame(){
  header('Observable.animationFrame() provides calls to requestAnimationFrame() as an observable sequence.');

  Observable
  .animationFrame(interval:500)
  .observe((v){
    print('$v');
  });
}

void fromFuture(){
  header('Observable.fromFuture() provides a value returned by a Future in an observable sequence.');

  Observable
    .fromFuture(new Future.immediate(42)) // get the dimensions of the DOM <body> tag (rect returns a Future<ElementRect>)
    .observe(
      (v) => print('Received from future: $v'),
      () => print('Sequence Complete.')
    );

}


void pace(){
  header('Observable.pace() takes an observable sequence and emits elements received in a paced interval.');

  Observable
    .range(1, 10)
    .pace(1500) //pacing sequence to 1.5 seconds each.
    .observe((v) => print(v), () => print('Sequence Complete.'));
}

void skipWhile(){
  header('Observable.skipWhile() skips the first n number of elements in an observable sequence where given function returns True.');

  Observable
    .range(1, 20)
    .skipWhile((v) => v < 6)
    .observe((v) => print('$v'), () => print('Sequence Complete.'));
}

void skip(){
  header('Observable.skip() skips the first n number of elements in an observable sequence, return subsequence elements.');

  Observable
    .range(1, 20)
    .skip(5)
    .observe((v) => print('$v'), () => print('Sequence Complete.'));

}

void sample(){
  header('Observable.sample() returns every nth element from a given observable sequence.');

  //sample every 5th element from the previous sequence
  Observable
    .range(1, 100)
    .sample(5)
    .observe((v) => print('Sampled: $v'), () => print ('Sequence Complete.'));

}

// Where 'D' represents the disposal of a sequence
// 1|--1--------1------1--->
//  |  |        |      |
// 2|---D       |      |
//  |  |        |      |
// S|--1--------1------1--->
void firstOf(){
  header("Observable.firstOf() Of a given list of sequences, .firstOf() propagates the first sequence to provide a value, disposing the others.");
  print('Run this demo several times to see the "winner" change.');

  var o1 = Observable
            .randomInt(1, 100, intervalLow:1, intervalHigh:1000, howMany:10)
            .apply((v)=> 'Sequence 1, value: $v');

  var o2 = Observable
            .randomInt(1, 100, intervalLow:1, intervalHigh:1000, howMany:10)
            .apply((v)=> 'Sequence 2, value: $v');

  var o3 = Observable
            .randomInt(1, 100, intervalLow:1, intervalHigh:1000, howMany:10)
            .apply((v)=> 'Sequence 3, value: $v');

  // chaining firstOf after o1 means o1 is included in the list automatically
  o1
  .firstOf([o2, o3])
  .observe((v) => print('$v'), () => print('Sequence Complete.'));

}


// 1|--1-----1-1-1--1----1--->
//  |  |     | | |  |    |
// S|--1-----1-1-1--1----1--->
random(){
  header("Observable.randomInt() (and also Observable.random() for Real numbers) generates a range of randum numbers at optionally random time intervals.");
  Observable
  .randomInt(0, 10, intervalLow: 1, intervalHigh: 1000, howMany: 20) //generating ints from 1 - 10 at intervals between 100 & 1000ms for 20 ticks.
  .observe((v) => print('$v'));
}

// 1|X
//  ||
// S|X
throwE(){
  header("Observable.throwE() Propagates an given Exception.");

  Observable
  .throwE(new Exception('Here is an exception.'))
  .observe((e){}, (){}, (e)=> print('Error! $e'));
}

// 1|1#
//  |||
//  |1#
returnValue(){
  header("Observable.returnValue() Returns the given value as an observable sequence and then terminates.");

  Observable
  .returnValue(42)
  .observe((e)=> print('$e'));
}

// Succeeds
// 1|---1#
//  |   ||
// S|---1#
//
// Fails
// 1|---1---1--->
//  |   |   |
// S|---1---X
single(){
  header("Observable.single() Returns the first element from a sequence and propogates an exception if any other elements are present.");

  Observable
  .range(1, 100)
  .single()
  .observe((e)=> print('$e'), (){}, (e) => print('Error! $e'));
}

// 1|----1---->
//  |    |
// S|----1#
first(){
  header("Observable.first() Returns the first element from the sequence and then terminates.");

  Observable
  .range(42, 100)
  .first()
  .observe((e)=> print('$e'));
}

// 1|----1-------1---1--->
//  |    f       f   f
// S|----1-------1---#
//
takeWhile(){
  header("Observable.takeWhile() Returns the first n elements while the conditional function returns true.");

  Observable
  .range(1, 100)
  .takeWhile((n) => n < 6)
  .observe((e)=> print('$e'));
}

// Given .take(4)
// 1|---1--1-1----1---1---->
//  |   |  | |    |
// S|---1--1-1----1#
take(){
  header("Observable.take() Returns the first n elements from an observable sequence.");

  Observable
  .range(1, 100)
  .take(5)
  .observe((e)=> print('$e'));

}

// 1|---1#
//  |   ||
// S|---1#
fromXMLHttpRequest(){
  header("Observable.fromXMLHttpRequest() Performs a GET request and returns the results for the given request type, in an observable sequence (singleton)");

  var uri = 'reactivedemo.dart'; //this should work if running locally...
  Observable
  .fromHttpRequest(uri, 'Accept', 'text/html')
  .single() //using single to enforce no additional values other than the data we requested...
  .observe((v)=>print('$v'), ()=> print('Request Complete.'), (e) => print ("Error! $e"));
}

// Given range(1, 5, 1)
// 1|--1--1--1--1--1#
//  |  |  |  |  |  ||
// S|--1--1--1--1--1#
void range(){
  header("Observable.range() Generates an observable sequence from a given start/end with optional step");

  print('1 to 5 in .5 step');
  Observable
    .range(1, 5, step: .5)
    .observe((v) => print(v));

  print('5 to 1 in .5 step');
  Observable
    .range(5, 1, step: .5)
    .observe((v) => print(v));
}

// 1|--1---1-1-----1--1----->
//  |  f   f f     f  f
// S|--1---1-1-----1--1----->
void apply(){
  header("Observable.apply() Applies a given function to each element in the sequence and returns the result in a new observable sequence");

  Observable
    .fromList(testlist)
    .apply((n) => n * n)
    .observe((v) => print('squared: $v'));
}

// 1|--1--1--1--1--1--1#
//  |  |  |  |  |  |  ||
// S|--1--1--1--1--1--1#
void unfold(){
  header("Observable.unfold() Generates a sequences from intial state and provides elements until conditional is false");

  // lets count 1 to 10
  Observable
    .unfold(1, (n) => n <= 10, (n) => n + 1, (n) => n)
    .observe((v) => print(v));
}

void throttle(){
  print("Throttle has it's own demo, see '/demos/throttle_demo/throttle_demo.dart");
}

// 1|--1--1--1------1--1-->
//  |  |  |  |
// S|--1--1--1-----X
void timeout(){
  header("Observable.timeout().  Returns an exception if an element in a sequence is not delivered within a given time allotment.");

  print('These shouldn\'t time out');
  Observable
    .timer(500, ticks: 4)
    .timeout(501)  //adjust this lower than 500 to see the exception throw.
    .observe((t) => print('Tick: $t'), (){}, (e)=> print('error!'));
}

// Given 't' = timestamp
// 1|--1--1----1--1------1---->
//  |  |  |    |  |      |
// S|--t--t----t--t------t---->
void timestamp(){
  header("Observable.timestamp() Returns a sequence of Date timestamps representing the arrival of each element in a given sequence.");

  Observable
    .timer(1300, ticks: 4)
    .timestamp()
    .observe((Date t) => print('Stamp: $t'),()=>print('Sequence Complete.'));

}

// Given 'L' = the list
// 1|--1--1--1--1--1#
//  |  |  |  |  |  |#
// S|---------------L#
void toList(){
  header("Observable.toList() Is a singleton sequence that returns all elements in a terminating sequence as a list.");

  // filters the sequence for even numbers and returns as a list
  Observable
    .fromList(testlist)
    .where((v) => v % 2 == 0)
    .toList()
    .observe((v) => print("List has ${v.length} elements.  First element is ${v[0]} and last is ${v.last()}"));
}

// 1|--1--1--1--1--1--1-->
//  |  f  f  f  f  f  f
// S|--1--1-----1-----1-->
void where(){
  header("Observable.where() Returns a sequence of elements that satisfy the given boolean function.");

  // filters the sequence for even numbers
  Observable
    .fromList(testlist)
    .where((v) => v % 2 == 0)
    .observe((v) => print(v));
}

// Where 'P' is the result of the function applied to pairs
// 1|--1--1----1--------1-->
//  |  |   \    \      /|
// 2|--2----2----2----2---->
//  |  f    f    f      f
// S|--P----P----P------P-->
void zip(){
  header("Observable.zip() Returns the value of a function applied to pairs of two observable sequences.");

  // setups some timers that tick at different intervals
  var o1 = Observable.timer(100, ticks: 10);
  var o2 = Observable.timer(1500, ticks: 20);

  // zip should 'synchronize' the ticks and emit them as pairs.
  // only 10 pairs should yield from the sequence, because o1's
  // tick maximum is 10.
  o1
    .zip(o2, (l, r) => [l, r]) // just return the pair as a list of two.
    .observe((v) => print('These values should be the same: ${v[0]}, ${v[1]}'));

}

// Where 'f' = false, 't' = true
//
// true case
// 1|---1---1---1---1---1---1-->
//  |   |   |   |   |   |   |
// S|---f---f---f---f---f---t#
//
// false case
// 1|---1---1---1---1---1---1#
//  |   |   |   |   |   |   |
// S|---f---f---f---f---f---f#
void contains(){
  // false until contains
  header("Observable.contains() Returns false until contained value is found or sequence terminates.");
  Observable
    .fromList(testlist)
    .contains(5)
    .observe((b)=> print(b));
}

// Where 'C' = the running count of elements in the sequence
// 1|--1-1----1--1---1------>
//  |  | |    |  |   |
// S|--C-C----C--C---C------>
void count(){
  // counting contains count iteration
  header("Here we are using Observable.count() tells us the number of attempts that Observable.contains() makes before returning true.");
  Observable
    .fromList(testlist)
    .contains(5)
    .count()
    .observe((c)=> print(c));
}

// 1|--1---1--1--1#
//  |  |   |  |  |
// 2|  |   |  |  | --2--2-2#
//  |  |   |  |  |   |  | ||
// S|--1---1--1--1---2--2-2#
void concat(){
  // concat 3 observable sequences into a single sequence
  header("Observable.concat() Concatenates observable sequences into one sequence.  Here we have 3 ([1,2,3], [4,5,6], [7,8,9])");
  Observable
    .fromList([1,2,3])
    .concat([Observable.fromList([4,5,6]), Observable.fromList([7,8,9])]) //concat our list sequence with two more sequences
    .observe((v) => print(v));
}

// Where 'R' = the result of each fold iteration
// 1|--1--1--1--1--->
//  |  f  f  f  f
// S|--R--R--R--R--->
void fold(){
  header("Folding (aggregating really) over a sequence.");
  Observable
    .fromList(testlist)
    .fold((v, n) => v + n, 0)
    .observe((v) => print(v));
}

// true case
// 1|--1--1---1--->
//  |  |
// S|--T#
//
// false case
// 1|---------#
//  |         |
// S|---------F#
void any(){
  header("Observable.any() Returns true if there are any values in the sequence, false otherwise.");
  Observable
    .fromList(testlist)
    .any()
    .observe((v)=> print('Should be true: $v.'));

  Observable
    .empty()
    .any()
    .observe((v) => print('Should be false: $v.'));

}

// Where buffer = 2
// Where B = the list containing buffered values
// 1|--1--1---1------1-1---->
//  |     |          |
// S|-----B----------B------>
void buffer(){
  header("Observable.buffer() Returns sequences as a series of buffered lists, based on buffer size provided.");
  Observable
    .fromList(testlist)
    .buffer(size: 2)
    .observe((v)=> print("Received buffered list of size ${v.length} with elements: ${v[0]}, ${v[1]}."));
}

// Where D = distinct values in the sequence
// 1|--1--1--1--1--1--1----1-->
//  |  |  |     |     |    |
// S|--D--D-----D-----D----D-->
void distinct(){
  header("Observable.distinct() Returns elements in the sequence that are distinct with respect to other elements.");
  Observable
    .fromList(testlist)
    .concat([Observable.fromList(testlist), Observable.fromList(testlist)]) //add a few copies of the same elements
    .distinct()
    .observe((v) => print(v));
}

// 1|--1--------1------1------#---->
//  |  |        |      |      |
// 2|----2---2------#  |      |
//  |  | |   |  |      |      |
// S|--1-2---2--1------1------#
void merge(){
  header("Observable.merge() Takes n sequences and merges elements into a single stream.");

  var o1 = Observable.timer(100, ticks: 10).apply((v) => 'Timer 1, tick $v');
  var o2 = Observable.timer(200, ticks: 10).apply((v) => 'Timer 2, tick $v');
  var o3 = Observable.timer(300, ticks: 10).apply((v) => 'Timer 3, tick $v');

  o1.merge([o2, o3]) //merges o1 with o2 and o3...
    .observe((v) => print(v));
}

void timer(){
  var status = document.query("#status");
  var counter = 0;

  //Timer
  Observable
  .timer(1000, ticks: 20)
  .observe((t) => status.text = '${++counter}',
    () => status.text = "Complete.");
}

void fromEvent(){
  var button = document.query("#btnClickDemo");
  var buttonStatus = document.query("#btnStatus");

  int inc = 0;

  //Lets count mouse clicks...
  Observable
    .fromEvent(button.on.click)
    .apply((_) => ++inc) //pass incremented count to the next method
    .observe((c) => buttonStatus.text = "$c clicks have occurred.");
}



void header(String msg){
  print("");
  print(msg);
  print("----------------------------------------------------------------------");
}

