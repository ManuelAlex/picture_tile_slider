import 'package:flutter/material.dart';

class NumberPicker extends StatefulWidget {
  const NumberPicker({super.key, required this.onSelected,required this.initialValue});
  final ValueChanged<int> onSelected;
  final int initialValue;

  @override
  State<NumberPicker> createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
 late int _number ;
  @override
  void initState() {
   _number=widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
      Wrap(
           //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
           alignment: WrapAlignment.center,
            
        children: [
          ConstrainedBox(
            constraints:const BoxConstraints(minWidth: 100,maxWidth: 320),
            child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
       border: Border.all(color: Colors.grey.shade600),
       
      ),
      child: 
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_number > 1) _number--;
                    });
                  },
                  child: const Text(
                    '-',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.black),
                  ),
                ),
              const  Divider(),
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    child: Center(
                      child: Text(
                        _number.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_number <= 16) _number++;
                    });
                  },
                  child: const Text(
                    '+',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color:Colors.black),
                  ),
                ),
              ],
            ),
          ),
         ),
          IconButton(
            onPressed: () {
              widget.onSelected(_number);
            },
            icon: const Icon(Icons.check),
               
          ),
        
        ],

      );
    
  }
}


