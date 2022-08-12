import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enerhisayo/models/LocalSharedPref.dart';
import 'package:enerhisayo/utils/utils.dart';
import 'package:enerhisayo/utils/size_helpers.dart';
import 'package:flutter/material.dart';

class EditActivityLog extends StatefulWidget {

  static const routeName = '/edit_activity_log';

  const EditActivityLog({ Key? key }) : super(key: key);

  @override
  State<EditActivityLog> createState() => _EditActivityLogState();

}

class _EditActivityLogState extends State<EditActivityLog> {

  // Variable Declarations
  final updateLogFormKey = GlobalKey<FormState>();  
  String _currentUserId='';
  String? activityLogId ='';
  String? activityLogTitle = '';
  String? activityLogContent = '';
  String newActivityLogTitle = '';
  String newActivityLogContent = '';

  // Update Activity Log Function in Database
  Future _updateActivityLog() async{

    final isValid = updateLogFormKey.currentState!.validate();

    if (!isValid) return;

    try{
      updateLogFormKey.currentState!.save();
      FocusScope.of(context).unfocus();

      final docActivityLogData = FirebaseFirestore.instance.collection('activityLogs').doc(activityLogId);

      await docActivityLogData.update({
         'title' : newActivityLogTitle,
          'content' : newActivityLogContent
      });

      Utils.showToast('Activity Log Updated Successfully');
      Navigator.pop(context);

    } catch (e){
      Utils.showToast(e.toString());
    }
  }

  // Delete Activity Log Function in Database
  Future _deleteActivityLog() async{

    try{
      FocusScope.of(context).unfocus();

      final docActivityLogData = FirebaseFirestore.instance.collection('activityLogs').doc(activityLogId);

      await docActivityLogData.delete();

      Utils.showToast('Activity Log Deleted Successfully');
      // Navigator.pop(context);

    } catch (e){
      Utils.showToast(e.toString());
    }
  }

  // Alert Dialog asking if User is sure to delete the record in Database
  Future<void> _deleteAlertDialog() async{
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Activity Log"),
          content: Text("Are you sure you want to delete this activity log?"),
          actions: [
            TextButton(
              child: Text("Yes"),
              onPressed:  () {
                _deleteActivityLog();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
            TextButton(
              child: Text("No"),
              onPressed:  () {
                Navigator.of(context).pop();  
              },
            ),
          ]
        );
      }
    );
  }

  // Editing Notes Form
  Widget _editNoteForm(){
    return Form(
      key: updateLogFormKey,
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
            initialValue: activityLogTitle.toString(),
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            enableSuggestions: false,
            decoration: const InputDecoration(
              hintText: 'Actity Log Title'
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => value!.isEmpty ? 'Enter title' : null,
            onSaved: (value)=> setState(() {
              newActivityLogTitle = value!;
            }),
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
                    initialValue: activityLogContent.toString(),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    expands: true,
                    textInputAction: TextInputAction.next,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      hintText: 'Actity Log Content'
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value!.isEmpty ? 'Enter content' : null,
                    onSaved: (value)=> setState(() {
                      newActivityLogContent = value!;
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //Get Data Stored in the Local Shared Prefs of Current User
  void _getDataFromLocal() async {
    _currentUserId = LocalSharedPreferences.getId();
  }

  // Run the Functions after Startup but before the build method 
  @override
  void didChangeDependencies(){
    final data = ModalRoute.of(context)?.settings.arguments as Map<String, String>;
    activityLogId = data['activityLogId'];
    activityLogTitle = data['activityLogTitle'];
    activityLogContent = data['activityLogContent'];
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
        title: Text('Edit Activity Log'),
        actions: [
          TextButton(
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600
              )
            ),
            onPressed: (){

              setState(() {
                // _deleteActivityLog();
                _deleteAlertDialog();
              });
            }, 
          ),
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
                _updateActivityLog();
              });
            }, 
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding:const EdgeInsets.only(top:15, left: 15, right: 15,),
          child: _editNoteForm()
        ),
      ),
      
    );
  }


}