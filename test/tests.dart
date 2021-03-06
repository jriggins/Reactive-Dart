import 'dart:html';
import 'package:reactive/reactive_browser.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';

/*
 * Unit Tests for Reactive Dart library
*/

//TODO migrate to the new async API...

main(){
  useHtmlEnhancedConfiguration();

  group("Observable constructors", (){
    usingCreate();
  });

  group("Operators", (){
    fromFuture();
    pace();
    skipWhile();
    skip();
    firstOf();
    sample();
    randomInt();
    random();
    fromHttpRequest();
    takeWhile();
    take();
    first();
    returnValue();
    range();
    unfold();
    throttle();
    timeout();
    timestamp();
    toList();
    fromEvent();
    throwE();
    count();
    apply();
    distinctUntilNot();
    where();
    zip();
    merge();
    distinct();
    delay();
    contains();
    empty();
    fold();
    any();
    buffer();
    concat();
    fromListGetsAllElements();
    timer();

  });
}


concat() {
  asyncTest('.concat()', 10, (){
    var i = 1;
    var o1 = Observable.range(1, 5);
    var o2 = Observable.range(6, 10);

    Observable
    .concat([o1, o2])
    .observe((v){
      Expect.equals(i++, v);
      callbackDone();
    });
  });
}


// TODO: test for handling of termination when
// buffer is partially full
buffer(){
    asyncTest('.buffer()', 5, (){
    var i = 1;

    Observable
    .range(1, 10)
    .buffer(size: 2) //buffer the sequence into chunks of 2
    .observe((v){
      Expect.isTrue(v is List);
      Expect.equals(2, v.length);
      Expect.equals(i++, v[0]);
      Expect.equals(i++, v[1]);
      callbackDone();
    });
  });
}

any(){

  asyncTest('.any() none', 1, (){

    Observable
      .empty()
      .any()
      .observe((v){
        Expect.isFalse(v);
        callbackDone();
      });
  });

  asyncTest('.any() some', 1, (){

    Observable
      .returnValue("foo")
      .any()
      .observe((v){
        Expect.isTrue(v);
        callbackDone();
      });
  });

}

fold() {
  asyncTest('.fold()', 10, (){
    var c = 1;
    var i = 1;

    Observable
      .range(1, 10)
      .fold((acc, v) => v + acc, 1)
      .observe(
        (v){
          i += c++; //match the fold operation
          Expect.equals(i, v);
          callbackDone();
        },
        (){},
        (e) => Expect.fail('$e')
      );
  });
}

empty(){
  asyncTest('.empty()', 1, (){
    var isEmpty = true;

    Observable
    .empty()
    .observe((_){
      isEmpty = false;
    },
    (){
      Expect.isTrue(isEmpty);
      callbackDone();
    });
  });
}

contains(){
  asyncTest('.contains()', 1, (){
    var c = false;

    Observable
    .range(1, 10)
    .contains(5)
    .observe((v){
      c = v;
    },
      (){
      Expect.isTrue(c);
      callbackDone();
    });
  });
}

delay() {
  asyncTest('.delay()', 1, (){
    Stopwatch sw = new Stopwatch();

    sw.start();

    Observable
    .range(1, 10)
    .delay(300)
    .observe((v){}, (){
      sw.stop();
      Expect.isTrue(sw.elapsedMilliseconds >= 300);
      callbackDone();
    });
  });
}

distinct() {
  asyncTest('.distinct()', 6, (){

    var o1 = Observable.range(1, 5);
    var o2 = Observable.range(1, 5);
    var i = 1;

    Observable
    .merge([o1, o2])
    .distinct()
    .observe((v){
      Expect.equals(i++, v);
      callbackDone();
    }, ()
    {
      Expect.equals(6, i);
      callbackDone();
      });
  });
}


merge() {
  asyncTest('.merge()', 1, (){
    var o1 = Observable.range(1, 5);
    var o2 = Observable.range(1, 5);

    Observable
    .merge([o1, o2])
    .count()
    .observe((v){
      Expect.equals(10, v);
      callbackDone();
    });
  });
}

zip() {
  asyncTest('.zip()', 5, (){
    var o1 = Observable.range(1, 5);
    var o2 = Observable.range(1, 5);
    var i = 1;

    Observable
    .zip(o1, o2, (v1, v2) => v1 * v2) //yield product (squares)
    .observe((v){
      Expect.equals(i * i++, v);
      callbackDone();
    });
  });
}

where() => asyncTest('.where()', 5, (){
  var i = 2;

  Observable
  .range(1, 10)
  .where((num v) => v % 2 == 0) //filter for even numbers
  .observe((v){
    Expect.equals(i, v);
    i += 2;
    callbackDone();
  });
});

distinctUntilNot() => asyncTest('.distinctUntilNot()', 1, (){

  var repeatingList = [1,2,3,4,5,1,2,3,4,5];

  Observable
  .fromList(repeatingList)
  .distinctUntilNot()
  .count()
  .observe((v){
    Expect.equals(5, v);
    callbackDone();
  });
});

apply() => asyncTest('.apply()', 5, (){
  var i = 1;

  Observable
  .range(1, 5)
  .apply((v) => 'number: $v')
  .observe((v){
    Expect.isTrue(v is String);
    Expect.isTrue(v.contains('${i++}'));
    callbackDone();
  });
});

count(){
  nullCountIsZero();
  countEqualsExpected();
}

throwE() => asyncTest('.throwE()', 1, (){

  Observable
  .throwE(new Exception('hello world.'))
  .observe(
    (v) => Expect.fail('should not emit value'),
    () => Expect.fail('should not terminate'),
    (e){
      Expect.isTrue(e is Exception);
      Expect.equals('Exception: hello world.', e.toString());
      callbackDone();
    });
});

fromEvent() => asyncTest('.fromEvent()', 1, (){

  Element element = document.query('#status');

  Expect.isNotNull(element);

  Observable
  .fromEvent(element.on.click)
  .observe((v){
    Expect.isTrue(v is Event);
    callbackDone();
  });

  //fire an event
  element.on.click.dispatch(new Event('click'));
});

toList() => asyncTest('.toList()', 1, (){

  Observable
  .randomInt(1, 10, howMany:5)
  .toList()
  .observe((v){
    Expect.isTrue(v is List);
    Expect.equals(5, v.length);
    callbackDone();
  });
});

timestamp() => asyncTest('.timestamp()', 1, (){

  Observable
  .returnValue(10)
  .timestamp()
  .observe((v){
    Expect.isTrue(v is Date);
    callbackDone();
  });
});

timeout() => asyncTest('.timeout()', 2, (){

  Observable
    .range(1, 5)
    .pace(100)
    .timeout(50)
    .observe(
      (v) => callbackDone(),
      () => Expect.fail('Should never terminate.'),
      (e) {
        Expect.isTrue(e is ObservableException);
        callbackDone();
      }
      );

});

throttle() => asyncTest('.throttle()', 2, (){

  //should emit no values
  Observable
    .range(1, 5)
    .throttle(100)
    .observe((v){
      Expect.fail('throttle failed.');
    },(){
      callbackDone();
    });

  //should emit 5 values
  Observable
    .range(1, 5)
    .pace(20)
    .throttle(10)
    .count()
    .observe((v){
      Expect.equals(5, v);
      callbackDone();
    });

});

unfold() => asyncTest('.unfold()', 10, (){
  int i = 1;

  //unfold from 1 to 10
  Observable
  .unfold(1, (v) => v <= 10, (v) => v += 1, (v) => v)
  .observe((v){
    Expect.equals(i++, v);
    callbackDone();
  });
});


range(){
  asyncTest('.range() Low To High', 5, (){
    int i = 1;

    Observable
    .range(1, 10, step:2)
    .observe((v){
      Expect.equals(i++, v);
      i++;
      callbackDone();
    });
  });

  asyncTest('.range() High To Low', 5, (){
    int i = 10;

    Observable
    .range(10, 1, step:2)
    .observe((v){
      Expect.equals(i--, v);
      i--;
      callbackDone();
    });
  });

}


returnValue() => asyncTest('.returnValue()', 1, (){

  Observable
  .returnValue("hello")
  .observe((v){
    Expect.equals("hello", v);
    callbackDone();
  });
});


first() => asyncTest('.first()', 2, (){
  var gotValue = false;

  Observable
  .range(1, 5)
  .first()
  .observe((v){
    Expect.isFalse(gotValue);
    gotValue = true;
    Expect.equals(1, v);
    callbackDone();
  });

  callbackDone();
});


take() => asyncTest('.take()', 4, (){

  var i = 1;

  Observable
    .range(1, 5)
    .take(4)
    .observe((v){
      Expect.equals(i++, v);
      callbackDone();
    });
});

takeWhile() => asyncTest('.takeWhile()', 1, (){

  Observable
    .range(1, 5)
    .takeWhile((v) => v < 3)
    .count()
    .observe((v){
      Expect.equals(2, v);
      callbackDone();
    });
});

fromHttpRequest() => asyncTest('.fromHttpRequest()', 1, (){
  var uri = 'tests.html'; //this should work if running locally...
  var testFileLength = 416; // the length of test.html if unmodified.

  Observable
    .fromHttpRequest(uri, 'Accept', 'text/html')
    .single() //using single to enforce no additional values other than the data we requested...
    .observe(
      (v){
        Expect.isTrue(v is String);
        Expect.equals(testFileLength, v.length);  //the length of unmodified test.html
        callbackDone();
      },
      (){},
      (e) {
        Expect.fail("exception thrown $e");
        callbackDone();
      });
});

random() => asyncTest('.random()', 1, (){

  //TODO test for invalid ranges
  //TODO test random intervals

  Observable
  .random(1, 10, howMany:10)
  .apply((v){
    Expect.isTrue(v is num);  // all values should be num
    return v;
  })
  .count()
  .observe((v){
    Expect.equals(10, v); //should produce 10 values
    callbackDone();
  });
});

randomInt() => asyncTest('.randomInt()', 1, (){

  //TODO test for invalid ranges
  //TODO test random intervals

  Observable
  .randomInt(1, 10, howMany:10)
  .apply((v){
    Expect.isTrue(v is num);  // all values should be integers
    return v;
  })
  .count()
  .observe((v){
    Expect.equals(10, v); //should produce 10 values
    callbackDone();
  });
});

sample() => asyncTest('.sample()', 1, (){

  Observable
    .range(1, 5)
    .sample(2) //sample rate of 2 from the list should yield 2 results
    .count()
    .observe((n) {
      Expect.equals(2, n);
      callbackDone();
    });
});

firstOf() => asyncTest('.firstOf()', 10, (){
  var tListStrings = const ['apple', 'pear', 'orange', 'grape', 'strawberry'];
  var o1 = Observable.range(1, 5);
  var o2 = Observable.fromList(tListStrings);

  // o1 should emit first since it is first in the list.
  Observable
    .firstOf([o1, o2])
    .observe((n) {
      Expect.isTrue(n is num);
      callbackDone();
    });

  o1 = Observable.range(1, 5);
  o2 = Observable.fromList(tListStrings);

  // o2 should emit first since o1 is delayed.
  Observable
    .firstOf([o1.delay(50), o2])
    .observe((n) {
      Expect.isTrue(n is String);
      callbackDone();
    });

});

skip() => asyncTest('.skip()', 1, (){

  Observable
    .range(1, 5)
    .skip(2) // removes the first two elements from the list
    .count()
    .observe((n){
      Expect.equals(3, n);
      callbackDone();
    });

});

skipWhile() => asyncTest('.skipWhile()', 1, (){

  Observable
    .range(1, 5)
    .skipWhile((v) => v < 3) // removes the first two elements from the list that are < 3
    .count()
    .observe((n){
      Expect.equals(3, n);
      callbackDone();
    });

});

pace() => asyncTest('.pace()', 1, (){

  var sw = new Stopwatch();
  sw.start();
  var interval = 30;

  Observable
    .range(1, 5)
    .pace(interval)
    .observe((_){}, (){
      sw.stop();
      Expect.isTrue(sw.elapsedMilliseconds > 4 * interval);
      sw.reset();
      callbackDone();
    });

});

fromFuture() => asyncTest('.fromFuture()', 2, (){
  Element e = document.query('#status');
  Expect.isNotNull(e);

  Observable
    .fromFuture(new Future.immediate(true))
    .observe((v){
      Expect.isTrue(v is bool);
      callbackDone();
    });

  callbackDone();
});

usingCreate() => asyncTest('Observable.create() creates and returns correct object', 1, (){
  var obs = Observable.create((IObserver o){
    o.next(5);
    o.complete();
  });

  Expect.isTrue(obs is IObservable);
  Expect.isTrue(obs is ChainableIObservable);

  obs.observe((v){
    Expect.equals(5, v);
    callbackDone();
  });
});

/// Validates that Observable.fromList emits the correct elements and correct total of elements.
fromListGetsAllElements() => asyncTest('.fromList() Emits all elements', 5, (){
  var i = 1;
  Observable
    .range(1, 5)
    .observe((n) {
      Expect.equals(i++, n);
      callbackDone();
    });
});

/// Checks if a sequence of null returns a count of 0 from Observable.count.
nullCountIsZero() => asyncTest('.count() Null count is 0', 1, (){
  Observable
    .fromList([])
    .count()
    .observe((total){
      Expect.equals(0, total);
      callbackDone();
      });

});

/// Checks if a sequence of elements returns the correct total via Observable.count.
countEqualsExpected() => asyncTest('.count() Count equals expected', 1, (){
  Observable
    .range(1, 5)
    .count()
    .observe((total){
      Expect.equals(5, total);
      callbackDone();
      });
});

//TODO: write test that verifies intervals are correct.
/// Validates that Observable.timer emits the correct number of ticks.
timer() => asyncTest('.timer() validate tick count', 1, (){
  Observable
    .timer(300, ticks: 5)
    .count()
    .observe((total){
      Expect.equals(5, total);
      callbackDone();
      });
});