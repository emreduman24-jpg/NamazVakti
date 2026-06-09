Widget _buildGunlukDualar() {
5125:     return ListView.builder(
5126:       itemCount: DUALAR.length,
5127:       itemBuilder: (context, index) {
5128:         final dua = DUALAR[index];
5129:         return Card(
5130:           elevation: 1.5,
5131:           shape: RoundedRectangleBorder(
5132:             borderRadius: BorderRadius.circular(16),
5133:           ),
5134:           margin: EdgeInsets.only(bottom: 12),
5135:           child: Padding(
5136:             padding: EdgeInsets.all(16.0),
5137:             child: Column(
5138:               crossAxisAlignment: CrossAxisAlignment.start,
5139:               children: [
5140:                 Text(
5141:                   dua['ad'] ?? '',
5142:                   style: TextStyle(
5143:                     fontWeight: FontWeight.bold,
5144:                     fontSize: 15,
5145:                     color: _greenColor,
5146:                   ),
5147:                 ),
5148:                 Divider(height: 12),
5149:                 Align(
5150:                   alignment: Alignment.centerRight,
5151:                   child: Text(
5152:                     dua['arapca'] ?? '',
5153:                     style: TextStyle(
5154:                       fontFamily: 'Traditional Arabic',
5155:                       fontSize: 18,
5156:                       height: 1.8,
5157:                       fontWeight: FontWeight.bold,
5158:                       color: Color(0xFF27A770),
5159:                     ),
5160:                     textAlign: TextAlign.right,
5161:                   ),
5162:                 ),
5163:                 SizedBox(height: 8),
5164:                 Text(
5165:                   "Anlam\u0131: ${dua['anlam']}",
5166:                   style: TextStyle(fontSize: 13, color: _textColor),
5167:                 ),
5168:               ],
5169:             ),
5170:           ),
5171:         );
5172:       },
5173:     );
5174:   }