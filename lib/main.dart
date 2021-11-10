import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rounded_loading_button/rounded_loading_button.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shayk',
      theme: ThemeData(
        textTheme: GoogleFonts.openSansTextTheme(
          Theme.of(context).textTheme,
        ),
        primarySwatch: Colors.deepOrange,
      ),
      home: MyHomePage(title: 'Shayk'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showText = false, sendEmailButtonEnabled = false;

  String shrinkBtnTitle = 'Expand';

  Widget initialWidget = SizedBox();

  final pdf = pw.Document();
  final String lifeSentence = '''
      Life is the aspect of existence that processes   acts   reacts   evaluates   and evolves through growth   reproduction and metabolism     The crucial difference between life and non  life   or non  living things   is that life uses energy for physical and conscious development   Life is anything that grows and eventually dies   i  e     ceases to proliferate and be cognizant   Can we say that viruses   for example   are cognizant   Yes   insofar as they react to stimuli   but they are alive essentially because they reproduce and grow   Computers are non  living because even though they can cognize   they do not develop biologically   grow     and cannot produce offspring   It is not cognition that determines life   then   it is rather proliferation and maturation towards a state of death   and death occurs only to living substances  
      
      Or is the question       What is the meaning   purpose   of life       That    s a real tough one   But I think that the meaning of life is the ideals we impose upon it   what we demand of it   I  ve come to reaffirm my Boy Scout motto   give or take a few words   that the meaning of life is to   Do good   Be Good   but also to Receive Good   The foggy term in this advice   of course   is   good     but I leave that to the intuitive powers that we all share  
      
      There are   of course   many intuitively clear examples of Doing Good   by retrieving a crying baby from a dumpster   by trying to rescue someone who  s drowning   Most of us would avoid murdering   and most of us would refrain from other acts we find intuitively wrong   So our natural intuitions determine the meaning of life for us   and it seems for other species as well   for those intuitions resonate through much of life and give it its purpose   
      
   
      
                  Tom Baranski   Somerset   New Jersey
      ''';

  late final ScrollController _listController;
  late final RoundedLoadingButtonController _loadingButtonController;

  @override
  void initState() {
    super.initState();

    _listController = ScrollController(
      initialScrollOffset: 0,
      keepScrollOffset: true,
    );

    _loadingButtonController = RoundedLoadingButtonController();
  }

  @override
  void didChangeDependencies() {
    _listController.addListener(bottomCheckListener);
    super.didChangeDependencies();
  }

  void bottomCheckListener() {
    if ((_listController.position.pixels -
            _listController.position.maxScrollExtent) <=
        50) {
      sendEmailButtonEnabled = true;
    } else {
      sendEmailButtonEnabled = false;
    }
    setState(() {});
  }

  void showTextFunction() {
    if (showText) {
      showText = false;
      shrinkBtnTitle = 'Expand';
      sendEmailButtonEnabled = false;
      setState(() {});
    }
  }

  void hideTextFunction() {
    if (!showText) {
      showText = true;
      shrinkBtnTitle = 'Shrink';
      setState(() {});
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> sendEmail(String attachmentFilePath) async {
    final MailOptions mailOptions = MailOptions(
      body: 'Notice for the rent. Kindly check the attachment below.',
      subject: 'Legal Issues',
      recipients: <String>[
        'jayjaydangar96@gmail.com',
        "rishabhpatel779@gmail.com"
      ],
      isHTML: true,
      attachments: [attachmentFilePath],
    );

    try {
      await FlutterMailer.send(mailOptions);
      _loadingButtonController.stop();
      await Future.delayed(Duration(seconds: 1));
      _loadingButtonController.success();
      log('Email sent successfully.');
    } on PlatformException catch (error) {
      log('Platform Exception, Try again');
      _loadingButtonController.error();
    }
    await Future.delayed(Duration(seconds: 1));
    _loadingButtonController.reset();
  }

  Future<String> savePDF() async {
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/legalnotice.pdf");
    await file.writeAsBytes(await pdf.save());
    log("Saved As PDF file in temporary Directory");
    return file.path;
  }

  Future<void> savePDFAndSendEmail() async {
    _loadingButtonController.start();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Text(
            lifeSentence,
            style: pw.TextStyle(
              fontSize: 18,
            ),
          ); // Center
        },
      ),
    ); //
    String filePath = await savePDF();
    await sendEmail(filePath);
  }

  @override
  void dispose() {
    _listController.removeListener(bottomCheckListener);
    _listController.dispose();
    super.dispose();
  }

  Widget buildSendEmailButtonButton() {
    return RoundedLoadingButton(
      color: Colors.deepOrange,
      borderRadius: 8,
      height: 36,
      child: Text(
        'Send Email',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      controller: _loadingButtonController,
      onPressed: () => savePDFAndSendEmail(),
    );
  }

  Widget buildDisabledButton() {
    return OutlinedButton(
      onPressed: () => null,
      child: Text(
        'Send Email',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ButtonStyle(
        foregroundColor: MaterialStateColor.resolveWith(
          (states) => (sendEmailButtonEnabled) ? Colors.orange : Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: ListView(
        controller: _listController,
        padding: EdgeInsets.all(16),
        children: [
          AnimatedContainer(
            duration: Duration(seconds: 1),
            key: UniqueKey(),
            height: (showText) ? null : 150,
            child: Text(lifeSentence),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: (sendEmailButtonEnabled)
                    ? buildSendEmailButtonButton()
                    : buildDisabledButton(),
                flex: 1,
              ),
              SizedBox(
                width: 16,
              ),
              Expanded(
                child: buildOutlinedButton(),
                flex: 1,
              ),
            ],
          )
        ],
      ),
    );
  }

  ElevatedButton buildOutlinedButton() {
    return ElevatedButton(
      child: Text(
        shrinkBtnTitle,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: () => (showText) ? showTextFunction() : hideTextFunction(),
      style: ButtonStyle(
        elevation: MaterialStateProperty.resolveWith((states) => 2),
        textStyle: MaterialStateProperty.resolveWith(
            (states) => TextStyle(color: Colors.black)),
        backgroundColor:
            MaterialStateProperty.resolveWith((states) => Colors.deepOrange),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
