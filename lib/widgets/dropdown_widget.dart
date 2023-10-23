import 'package:flutter/material.dart';

class DropdownWidget extends StatefulWidget {
  const DropdownWidget({
    required this.title,
    required this.options,
    required this.onChanged,
    this.defaultValue,
  });

  final String title;
  final List<String> options;
  final String? defaultValue;
  final ValueChanged<String> onChanged;

  @override
  State<DropdownWidget> createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  String title = '';
  List<String> options = [];
  bool isSelected = false;
  String selectedOption = '';
  String? _value;

  @override
  void initState() {
    super.initState();
    options = widget.options;
    _value = (widget.defaultValue != null && widget.defaultValue != '')
        ? options.contains(widget.defaultValue)
            ? widget.defaultValue
            : options.first
        : options.first;
    title = widget.title;
  }

  @override
  Widget build(final BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 8,
      ),
      decoration: const BoxDecoration(
        color: Color(0xff0e537a),
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Container(
              alignment: AlignmentDirectional.centerEnd,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                value: _value,
                dropdownColor: Colors.blue,
                underline: Container(),
                iconSize: 40,
                iconEnabledColor: Colors.black,
                items: options
                    .map(
                      (final value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    )
                    .toList(),
                onTap: () {
                  setState(() {
                    isSelected = true;
                  });
                },
                onChanged: (final value) async {
                  setState(() {
                    _value = value;
                  });
                  if (value != null) {
                    widget.onChanged(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
