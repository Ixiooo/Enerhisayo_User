import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enerhisayo/models/ActivityLogData.dart';
import 'package:enerhisayo/models/LocalSharedPref.dart';
import 'package:enerhisayo/utils/utils.dart';
import 'package:enerhisayo/utils/size_helpers.dart';
import 'package:flutter/material.dart';

class AddActivityLog extends StatefulWidget {

  static const routeName = '/add_activity_log';

  const AddActivityLog({ Key? key }) : super(key: key);

  @override
  State<AddActivityLog> createState() => _AddActivityLogState();
}

class _AddActivityLogState extends State<AddActivityLog> {

  // Variable Declarations
  final addLogFormKey = GlobalKey<FormState>();  
  final logTitleController = TextEditingController();
  final logContentController = TextEditingController();
  String _currentUserId='';

  // Add Activity Log Function to Database
  Future _addActivityLog() async{

    final isValid = addLogFormKey.currentState!.validate();

    if (!isValid) return;

    try{
      FocusScope.of(context).unfocus();

      final docActivityLogData = FirebaseFirestore.instance.collection('activityLogs').doc();
      final activityLogData = ActivityLogData(
        id: docActivityLogData.id,
        user_id: _currentUserId,
        title: logTitleController.text.trim(),
        content: logContentController.text.trim(),
        createdAt: DateTime.now()
      );
      
      final activityLogDataJson = activityLogData.toJson();

      await docActivityLogData.set(activityLogDataJson);
      Utils.showToast('Activity Log Added Successfully');
      _clearInput();
      Navigator.pop(context);

    } catch (e){
      Utils.showToast(e.toString());
    }
  }

  // Adding Notes Form
  Widget _addNoteForm(){
    return Form(
      key: addLogFormKey,
      child: Column(
        children: [

          // Title
          Row(
            children: [
              Column(
                children: const [
                  Text(
                    'Actity Log Title',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
    
          TextFormField(
            textCapitalization: TextCapitalization.sentences,
            controller: logTitleController,
            textInputAction: TextInputAction.next,
            enableSuggestions: false,
            decoration: const InputDecoration(
              hintText: 'Actity Log Title'
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => value!.isEmpty ? 'Enter title' : null,
          ),

          SizedBox(height: 15), 

          // Content
          Row(
            children: [
              Column(
                children: const [
                  Text(
                    'Actity Log Content',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
    
          Container(
            height: displayHeight(context)*0.7,
            child: Column(
              children: [
                Expanded(
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    expands: true,
                    controller: logContentController,
                    textInputAction: TextInputAction.next,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      hintText: 'Actity Log Content'
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value!.isEmpty ? 'Enter content' : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Clear the Input in the From
  void _clearInput(){
    logTitleController.clear();
    logTitleController.clear();
  }

  // Delete The Values when Screen is Closed
  void dispose(){
    logTitleController.dispose();
    logContentController.dispose();

    super.dispose();
  }
 
  //Get Data Stored in the Local Shared Prefs of Current User
  void _getDataFromLocal() async {
    _currentUserId = LocalSharedPreferences.getId();
  }
 
  // Run the Functions on Startup
  @override
  void initState() {
    super.initState();
    _getDataFromLocal();
  }

  // Build the User Interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Activity Log'),
        actions: [
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600
              )
            ),
            onPressed: (){
              setState(() {
                _addActivityLog();
              });
            }, 
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding:const EdgeInsets.only(top:15, left: 15, right: 15,),
          child: _addNoteForm()
        ),
      ),
      
    );
  }
}