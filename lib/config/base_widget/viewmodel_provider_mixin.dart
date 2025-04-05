import "package:flutter/material.dart";
import "package:provider/provider.dart";

mixin ViewModelMixin<T extends ChangeNotifier> {
  T vm(BuildContext context, {bool listen = false}) => Provider.of<T>(context, listen: listen);
}
