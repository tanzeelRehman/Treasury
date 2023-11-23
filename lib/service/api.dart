// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:logger/logger.dart';
// import 'package:xml/xml.dart';

// class API {
//   static sendPostRequest(String weight, String fpostalcode, String dpostalcode,
//       double discount) async {
//     //! Define the URL endpoint for your API
//     String url = 'https://ct.soa-gw.canadapost.ca/rs/ship/price'.trim();

//     //! Define the request headers
//     Map<String, dynamic> headers = {
//       'Accept': 'application/vnd.cpc.ship.rate-v4+xml',
//       'Content-Type': 'application/vnd.cpc.ship.rate-v4+xml',
//       'Authorization':
//           'Basic NmU5M2Q1Mzk2ODg4MTcxNDowYmZhOWZjYjk4NTNkMWY1MWVlNTdh',
//       'Accept-Language': 'en-CA',
//     };

//     //! Define the XML body
//     String xmlBody = '''
//     <mailing-scenario xmlns="http://www.canadapost.ca/ws/ship/rate-v4">
//       <customer-number>2004381</customer-number>
//       <contract-id>42708517</contract-id>
//       <parcel-characteristics>
//         <weight>$weight</weight>
//       </parcel-characteristics>
//       <origin-postal-code>$fpostalcode</origin-postal-code>
//       <destination>
//         <domestic>
//           <postal-code>$dpostalcode</postal-code>
//         </domestic>
//       </destination>
//     </mailing-scenario>
//   ''';

//     //! Create an instance of Dio and set the headers
//     Dio dio = Dio();
//     dio.options.headers.addAll(headers);

//     //! Convert the XML body to a format that Dio can send
//     var requestBody = XmlDocument.parse(xmlBody).toXmlString();

//     //! Make the POST request
//     Response response = await dio.post(
//       url,
//       data: requestBody,
//     );

//     if (response.statusCode == 200) {
//       //! Parsing XML from response
//       final document = XmlDocument.parse(response.data);

//       //! Extracting all price-quote elements from XML
//       final priceQuotes = document.findAllElements('price-quote');

//       //! List Which will store JSON Objects
//       List<Map<String, dynamic>> quotes = [];

//       for (var quote in priceQuotes) {
//         //! Service name
//         final serviceName = quote.getElement('service-name')?.innerText ?? '';
//         //! Base price
//         final base =
//             quote.findElements('price-details').first.innerText.substring(0, 5);
//         //! GST percentage
//         final gstPercent = quote
//             .getElement('price-details')!
//             .getElement('taxes')!
//             .firstChild!
//             .innerText;
//         //! GST Amount
//         final gstAmount =
//             quote.getElement('price-details')!.getElement('due')!.innerText;

//         //! Expected Delivery Date
//         final expectedDeliveryDate = quote
//                 .getElement('service-standard')
//                 ?.getElement('expected-delivery-date')
//                 ?.innerText ??
//             '';

//         //! Expected Transit Time
//         final expectedTransitTime = quote
//                 .getElement('service-standard')
//                 ?.getElement('expected-transit-time')
//                 ?.innerText ??
//             '';

//         //! Discount Calculation
//         //* Step 1 Convert discount % in to decimel
//         final discountDecimal = discount / 100;
//         //* Step 2: Calculate the discount amount by multiplying the base price by the discount
//         final discountAmount = double.parse(base) * discountDecimal;
//         //* Step 3: Subtract the discount amount from the base price to get the discounted price.
//         final totaldiscountprice = double.parse(base) - discountAmount;

//         //! Creating Custom JSON structure
//         final quoteInfo = {
//           'service-name': serviceName,
//           'base': base,
//           'taxes': {
//             'gst-percent': gstPercent,
//             'gst-amount': gstAmount,
//           },
//           'expected-delivery-date': expectedDeliveryDate,
//           'expected-transit-time': expectedTransitTime,
//           'discount-percent': discount,
//           'total-discount': totaldiscountprice.toStringAsFixed(2)
//         };

//         //! Adding JSON in quotes list
//         quotes.add(quoteInfo);
//       }
//       Logger().i(quotes);
//       //! Use this if you want to return JSON as string [If use this, then change return type of function, Make it String]
//       final jsonDataString = json.encode({'results': quotes});
//       //! Use this if you want to return JSON data without encoding it
//       final jsonData = {'results': quotes};

//       //! Returning value as a JSON
//       return jsonData;
//     } else {
//       return {'Error': 'Request failed with status: ${response.statusCode}'};
//     }
//   }
// }
