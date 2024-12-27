import 'package:flutter/material.dart';

import 'helpers.dart';

class GameFrame extends StatelessWidget {
  const GameFrame({super.key,required this.child,
  });
final Widget child;
  @override
  Widget build(BuildContext context) {
   final MediaQueryData mediaQuery = MediaQuery.of(context);
  final  bool isMobile = mediaQuery.size.width < 600; 
  
    return    Padding(
      padding:isMobile? EdgeInsets.zero: const EdgeInsets.all(40.0),
      child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 40,
                    color: woodColor,
                  ),
                  
                  borderRadius: BorderRadius.circular(30),
                
                     
                ),
              child:Container(
                decoration:  BoxDecoration(color: woodColor,
                boxShadow:const [
      
                  BoxShadow(
                    offset: Offset(2, 2),
                    color: Colors.black38,
                blurStyle: BlurStyle.inner,spreadRadius: 6,blurRadius: 80),
                     BoxShadow(
                      offset: Offset(-2, -2),
                      color: Colors.black38,
                blurStyle: BlurStyle.inner,spreadRadius: 6,blurRadius: 80),
                ]     
                ) ,
                child: child,
              ),
              ),
    );
  }
}