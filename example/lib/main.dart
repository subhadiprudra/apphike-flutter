import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:apphike/apphike.dart';
import 'package:apphike/src/apphike_core.dart';
import 'package:apphike/src/apphike_screen_observer.dart';
import 'dart:ui';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap your app with Apphike widget to initialize analytics and tracking
    return Apphike(
      apiKey:
          'diJFrShPSQiBNw4UfCkZpg5GYcGZHwbg', // Replace with your actual API key
      userIdentifier: 'user@example.com', // Optional: identify your user

      child: MaterialApp(
        navigatorObservers: [ApphikeScreenObserver()],
        title: 'Apphike Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  int _rating = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    // Track custom event when counter is incremented
    Apphike.trackEvent(
      eventName: 'counter_incremented',
      eventData: 'Counter value: $_counter',
    );
  }

  void _submitRating() async {
    if (_rating > 0) {
      try {
        await ApphikeCore.submitRatingAndReview(
          rating: _rating,
          review: 'Great app! Rating: $_rating stars',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rating submitted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error submitting rating: $e')),
          );
        }
      }
    }
  }

  void _submitFeedback() async {
    try {
      await ApphikeCore.submitCommunication(
        message: 'This is a test feedback message from the demo app',
        type: 'feedback',
        email: 'user@example.com',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting feedback: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Apphike Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Counter Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Counter with Event Tracking',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 100,
                      child: _counter > 5
                          ? Row(
                              children: [
                                Container(
                                  width:
                                      200, // This will overflow the 100px parent
                                  height: 50,
                                  color: Colors.red.shade100,
                                  child: const Text(
                                    'OVERFLOW ERROR! This text is too wide for the container and will cause a render overflow.',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Each tap tracks a custom event. Click more than 5 times to trigger overflow error!',
                              style: TextStyle(fontSize: 10),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _incrementCounter,
                      child: const Text('Increment & Track Event'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Rating Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Rating & Review',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Submit a rating and review'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    Text('Rating: $_rating/5'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _rating > 0 ? _submitRating : null,
                      child: const Text('Submit Rating'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Feedback Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Send Feedback',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Submit general feedback or bug reports'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submitFeedback,
                      child: const Text('Submit Test Feedback'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Navigation Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Screen Analytics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Navigate to see screen tracking in action'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SecondScreen(),
                            settings: const RouteSettings(name: '/second'),
                          ),
                        );
                      },
                      child: const Text('Go to Second Screen'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Custom Events Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Custom Events',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Track custom events with optional data'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Apphike.trackEvent(eventName: 'button_clicked');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Event tracked: button_clicked',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Track Simple Event'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Apphike.trackEvent(
                                eventName: 'user_action',
                                eventData:
                                    'Action performed at ${DateTime.now()}',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Event tracked: user_action with data',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Track Event with Data'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Error Testing Section
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Error Testing',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Test FlutterError.onError handling',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),

                    // Render Flex Overflow Error
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Render Overflow Error'),
                            content: SizedBox(
                              width: 100, // Very small width
                              height: 50,
                              child: Row(
                                children: [
                                  Container(
                                    width: 200, // Much larger than parent
                                    height: 40,
                                    color: Colors.red,
                                    child: const Text('This will overflow!'),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                      ),
                      child: const Text('Trigger Overflow Error'),
                    ),

                    const SizedBox(height: 8),

                    // Null Widget Error
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ErrorScreen(),
                            settings: const RouteSettings(name: '/error'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                      ),
                      child: const Text('Go to Error Screen'),
                    ),

                    const SizedBox(height: 8),

                    // Division by Zero Error (caught by Flutter)
                    ElevatedButton(
                      onPressed: () {
                        try {
                          // This will cause a build error
                          throw FlutterError(
                            'Manual Flutter Error for Testing',
                          );
                        } catch (e) {
                          // Re-throw as FlutterError to test error handling
                          FlutterError.reportError(
                            FlutterErrorDetails(
                              exception: e,
                              library: 'apphike_demo',
                              context: ErrorDescription('Manual error trigger'),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Error reported to FlutterError.onError',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                      ),
                      child: const Text('Trigger Manual Error'),
                    ),

                    const SizedBox(height: 8),

                    // Widget State Error
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Widget Error Demo'),
                            content: SizedBox(
                              height: 100,
                              child: Column(
                                children: [
                                  const Text(
                                    'This will trigger a widget error:',
                                  ),
                                  const SizedBox(height: 10),
                                  // This should cause a flex overflow error
                                  Row(
                                    children: List.generate(
                                      10,
                                      (index) => Container(
                                        width: 50,
                                        height: 30,
                                        margin: const EdgeInsets.all(2),
                                        color: Colors.red.shade200,
                                        child: Text('$index'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                      ),
                      child: const Text('Trigger Widget Error'),
                    ),

                    const SizedBox(height: 8),

                    // Widget State Error
                    ElevatedButton(
                      onPressed: () {
                        // Try to access widget after dispose (this might cause an error)
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (mounted) {
                            setState(() {
                              // Force an error by trying to build invalid widget
                              _counter =
                                  -1; // This will be used to trigger error in ErrorWidget
                            });
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                      ),
                      child: const Text('Trigger State Error'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Section
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About This Demo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('This demo showcases all Apphike features:'),
                    const SizedBox(height: 8),
                    const Text(
                      '• Session Analytics - Automatic session tracking',
                    ),
                    const Text('• Screen Analytics - Navigation tracking'),
                    const Text('• Custom Events - Track specific user actions'),
                    const Text('• Feedback & Reviews - Collect user feedback'),
                    const Text(
                      '• Communication - Bug reports & feature requests',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Note: Make sure to configure your API key and backend endpoint for full functionality.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Second Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('This screen navigation is being tracked!'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Track custom event before going back
                Apphike.trackEvent(
                  eventName: 'back_button_pressed',
                  eventData: 'User navigating back from second screen',
                );
                Navigator.pop(context);
                Apphike.onScreenPopped('/second');
              },
              child: const Text('Go Back'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Apphike.trackEvent(
                  eventName: 'second_screen_action',
                  eventData: 'User performed action on second screen',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Action tracked on second screen!'),
                  ),
                );
              },
              child: const Text('Track Action on This Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Screen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              color: Colors.red,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '⚠️ Error Testing Screen',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Assertion Error Widget
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Assertion Error Test',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // This will trigger an assertion error
                        assert(false, 'This is a test assertion error');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                      ),
                      child: const Text('Trigger Assertion Error'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Null Check Error
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Null Check Error Test',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        try {
                          String? nullString;
                          int length = nullString!.length; // This will throw
                          print(length); // Won't be reached
                        } catch (e) {
                          FlutterError.reportError(
                            FlutterErrorDetails(
                              exception: e,
                              library: 'apphike_demo',
                              context: ErrorDescription(
                                'Null check error test',
                              ),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Null check error reported'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                      ),
                      child: const Text('Trigger Null Check Error'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Range Error
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Range Error Test',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        try {
                          List<int> list = [1, 2, 3];
                          int value = list[10]; // This will throw RangeError
                          print(value); // Won't be reached
                        } catch (e) {
                          FlutterError.reportError(
                            FlutterErrorDetails(
                              exception: e,
                              library: 'apphike_demo',
                              context: ErrorDescription('Range error test'),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Range error reported'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                      ),
                      child: const Text('Trigger Range Error'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Widget with Intentional Error
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Widget Build Error Test',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('This widget has an intentional layout error:'),
                    const SizedBox(height: 8),
                    // This will cause a layout error - trying to fit infinite width in finite space
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              color: Colors.red.shade100,
                              child: const Text(
                                'This might cause layout issues',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Back Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
