Widget _buildZikirmatik() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Hedef Zikir: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<int>(
              value: _zikirTarget,
              items: const [
                DropdownMenuItem(value: 33, child: Text("33")),
                DropdownMenuItem(value: 99, child: Text("99")),
                DropdownMenuItem(value: 100, child: Text("100")),
                DropdownMenuItem(value: 1000, child: Text("1000")),
                DropdownMenuItem(value: 9999, child: Text("Limitsiz")),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _zikirTarget = val;
                    _zikirCount = 0;
                  });
                  _repository.setZikirTarget(val);
                  _repository.setZikirCount(0);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _incrementZik
          child: Container(
            width: 200,
                          ],
                        ),
                        child: const Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "K",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "G",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "B",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "D",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Compass Needle (Qibla pointer) pointing to 137° (Prayer rug Seccade)
                    Transform.rotate(
                      angle: (needleRotation * math.p
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
            ),
          ),
        ),
      ],
    );
  }