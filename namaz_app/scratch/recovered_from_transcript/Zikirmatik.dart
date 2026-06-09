Widget _buildZikirmatik() {
     final zikir = _zikirData[_selectedZikirId] ?? _zikirData['subhanallah']!;
     return SingleChildScrollView(
@@ -4089,14 +4089,17 @@
                     ),
                     Text(
                       _zikirTarget == 9999 ? "/ \u221e" : "/ $_zikirTarget",
-                      style: TextStyle(fontSize: 13, color: Colors.grey),
-                    ),
-                  ],
-                ),
-              ),
-            ),
-          ),
-          SizedBox(height: 24),
+                      style: TextStyle(fontSize: 13, color: Colors.grey,
+                      ),
+                    ),
+                  ],
+                ),
+              ),
+            ),
+          ),
+          SizedBox(height: 16),
+          _buildWeekViewChart(),
+          SizedBox(height: 16),
           // Zikir actions
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
[diff_block_end]

Please note that the above snippet only shows the MODIFIED lines from the last change. It shows up to 3 lines of unchanged lines before and after the modified lines. The actual file contents may have many more lines not shown."}