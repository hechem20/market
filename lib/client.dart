import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gateway/commande.dart';
import 'package:permission_handler/permission_handler.dart';
class ClientPage extends StatefulWidget {
  @override
  _ClientPageState createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  late Web3Client _ethClient;
  final String _rpcUrl = "https://sepolia.morphl2.io";
     

  final String _privateKey = "0xcb19d6e37bbcdea36a35d8d0b23dbf51bbcdcf8f56beef118d1d7342bd6380bd";
  final EthereumAddress _contractAddr = EthereumAddress.fromHex("0xC8F61a9EfD59833EaFf89f25C2f53187Be1ef06C");
  final EthereumAddress _orderContractAddr = EthereumAddress.fromHex("0x52091e493E964ac257ddd7c6739505C1E58682a9");

  late DeployedContract _productContract;
  late DeployedContract _orderContract;
  late ContractFunction _getProduct;
  late ContractFunction _buyProduct;
  late ContractFunction _addOrder;
  late ContractFunction _getAllOrders;

  late EthereumAddress _ownAddress;

  List<Map<String, dynamic>> products = [];
  List<dynamic> orders = [];
  BigInt balance = BigInt.zero;
  int _selectedTab = 0;
bool _scanned = false;
bool showScanner = false;
String qrId = '';
  @override
void initState() {
  super.initState();
  _ethClient = Web3Client(_rpcUrl, Client());
  _initialize();
}

Future<void> _initialize() async {
    try {
  await _loadContracts(); // attend que le contrat soit chargé
  _getProduct = _productContract.function("getProduct");
  _buyProduct = _productContract.function("buyProduct");

  _addOrder = _orderContract.function("addOrder");
  _getAllOrders = _orderContract.function("getAllOrders");

  final credentials = await _ethClient.credentialsFromPrivateKey(_privateKey);
  _ownAddress = credentials.address;
  await _getBalance();    // si tu veux attendre le solde
  await _fetchProducts();
   } catch (e) {
    print("Initialization error: $e");
  }
}

  Future<void> _loadContracts() async {
    String abiProduct = '''[
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "price",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "benefit",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "seller",
				"type": "address"
			}
		],
		"name": "ProductAdded",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			}
		],
		"name": "ProductDeleted",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "buyer",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "seller",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "price",
				"type": "uint256"
			}
		],
		"name": "ProductPurchased",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "price",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "benefit",
				"type": "uint256"
			}
		],
		"name": "ProductUpdated",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "price",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "benefit",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "qrCodeHash",
				"type": "string"
			}
		],
		"name": "addProduct",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			}
		],
		"name": "buyProduct",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			}
		],
		"name": "deleteProduct",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getAllProducts",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "id",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "price",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "benefit",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "qrCodeHash",
						"type": "string"
					},
					{
						"internalType": "address payable",
						"name": "seller",
						"type": "address"
					},
					{
						"internalType": "bool",
						"name": "exists",
						"type": "bool"
					}
				],
				"internalType": "struct VendorProductStore.Product[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			}
		],
		"name": "getProduct",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "id",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "price",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "benefit",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "qrCodeHash",
						"type": "string"
					},
					{
						"internalType": "address payable",
						"name": "seller",
						"type": "address"
					},
					{
						"internalType": "bool",
						"name": "exists",
						"type": "bool"
					}
				],
				"internalType": "struct VendorProductStore.Product",
				"name": "",
				"type": "tuple"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "seller",
				"type": "address"
			}
		],
		"name": "getSellerProfit",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getTotalBenefit",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "nextId",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "products",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "price",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "benefit",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "qrCodeHash",
				"type": "string"
			},
			{
				"internalType": "address payable",
				"name": "seller",
				"type": "address"
			},
			{
				"internalType": "bool",
				"name": "exists",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "sellerProfits",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "totalBenefit",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "price",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "benefit",
				"type": "uint256"
			}
		],
		"name": "updateProduct",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]''';
    String abiOrder = """ [
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "string",
				"name": "productName",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "price",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "clientName",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "clientAddressText",
				"type": "string"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "clientWallet",
				"type": "address"
			}
		],
		"name": "OrderAdded",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_productName",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "_price",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "_clientName",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_clientAddressText",
				"type": "string"
			}
		],
		"name": "addOrder",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getAllOrders",
		"outputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "productName",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "price",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "clientName",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "clientAddressText",
						"type": "string"
					},
					{
						"internalType": "address",
						"name": "clientWallet",
						"type": "address"
					}
				],
				"internalType": "struct OrderManager.Order[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getOrderCount",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "orders",
		"outputs": [
			{
				"internalType": "string",
				"name": "productName",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "price",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "clientName",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "clientAddressText",
				"type": "string"
			},
			{
				"internalType": "address",
				"name": "clientWallet",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]  """;

    _productContract = DeployedContract(
        ContractAbi.fromJson(abiProduct, "ProductStore"), _contractAddr);
   _orderContract = DeployedContract(
        ContractAbi.fromJson(abiOrder, "OrderManager"), _orderContractAddr);

    }
void _onQrDetected(BarcodeCapture capture) async {
	
	
  if (_scanned) return;

  final barcodes = capture.barcodes;
  if (barcodes.isEmpty) return;

  final raw = barcodes.first.rawValue;
  if (raw == null || !raw.startsWith("pay:")) return;

  setState(() {
    _scanned = true;
  });

  final parts = raw.split(":");
  print(parts);
  // Ici tu attends format pay:id:name:price, donc length == 4
  if (parts.length != 2) {
    _showError("QR invalide");
    setState(() => _scanned = false);
    return;
  }

  final id = int.tryParse(parts[1])!;
  final getProductFunction =  _productContract .function("getProduct");

// Appel de la fonction
final result = await _ethClient.call(
  contract: _productContract ,
  function: getProductFunction,
  params: [BigInt.from(id)], // par exemple, id=1
);

// Analyse du résultat
var resul=result[0];
 final name= resul[1] as String;
 final price= resul[2] as BigInt;
  

  if (id == null || price == null) {
    _showError("QR invalide (format)");
    setState(() => _scanned = false);
    return;
  }

  final addressController = TextEditingController();

  final address = await showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Adresse Wallet"),
      content: TextField(
        controller: addressController,
        decoration: InputDecoration(hintText: "0x..."),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, addressController.text),
          child: Text("Confirmer"),
        ),
      ],
    ),
  );

  if (address == null || address.isEmpty) {
    setState(() => _scanned = false);
    return;
  }

  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Confirmer le paiement"),
      content: Text(
          "Payer $name pour ${(price / BigInt.from(1e6)).toDouble().toStringAsFixed(2)} USDT à $address ?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text("Payer"),
        ),
      ],
    ),
  );

  if (confirm == true) {
    await _payProduct(id, price, name, address);
  }

  setState(() => _scanned = false); // reset for another scan
}

Future<void> askCameraPermission() async {
  var status = await Permission.camera.status;
  if (!status.isGranted) {
    await Permission.camera.request();
  }
}
  Future<void> _getBalance() async {
    EtherAmount bal = await _ethClient.getBalance(_ownAddress);
    setState(() {
      balance = bal.getInWei;
    });
  }

  Future<void> _fetchProducts() async {
  List<Map<String, dynamic>> temp = [];

  for (int i = 9; i < 10; i++) {
    try {
      final result = await _ethClient.call(
        contract: _productContract,
        function: _getProduct,
        params: [BigInt.from(i)],
      );
	  print(result[0]);
      var resul=result[0];
      // Vérifie que le prodsuit existe (optionnel si ton contrat a un champ "exists")
      if (result.isNotEmpty && result[0].toString().isNotEmpty) {
        temp.add({
          "id": (resul[0] as BigInt).toInt(),
          "name": resul[1].toString(),
          "price": (resul[2] as BigInt).toInt(),
          "benifice": (resul[3] as BigInt).toInt(),
          "qrCode": resul[4].toString(),
          "seller": resul[5].toString(),
        });
     }
    } catch (e) {
      // Tu peux logger pour déboguer :
      print("Erreur à l'index $i: $e");
      break; // Stoppe à la première erreur (ex : index dépassé)
    }
  }

  setState(() {
    print(temp);
    products = temp;
  });
}


  Future<void> _fetchOrders() async {
    final result = await _ethClient.call(
        contract: _orderContract, function: _getAllOrders, params: []);
    setState(() {
      orders = result[0]; // result est un tuple avec un tableau d'orders
    });
  }

  Future<void> _payProduct(int id, BigInt price, String name,String walletAddress) async {
    if (balance < price) {
      _showMessage("Pas assez de USDT. Conversion en cours...");
      await _simulateTokenSwap();
    }

    final credentials = await _ethClient.credentialsFromPrivateKey(_privateKey);

    await _ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _productContract,
        function: _buyProduct,
        parameters: [BigInt.from(id)],
        value: EtherAmount.inWei(price),
      ),
      chainId:1337 ,
    );

    // Ajouter l’ordre
    await _ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _orderContract,
        function: _addOrder,
        parameters: [
          name,
          price,
          "jack", // mettre un vrai nom si disponible
          walletAddress
        ],
      ),
      chainId: 1337,
    );

    _showMessage("✅ Paiement et commande enregistrés !");
    _getBalance();
    _fetchOrders();
  }

  Future<void> _simulateTokenSwap() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      balance += BigInt.from(1e18.toInt()); // Simule +1 USDT
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
void _showError(String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Erreur"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("OK"),
        ),
      ],
    ),
  );
}

  /*void _scanQR() async {
    String scannedId = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QRScannerPage()),
    );

    int id = int.parse(scannedId);
    Map<String, dynamic> product = products.firstWhere((p) => p["id"] == id);
    await _payProduct(id, product["price"], product["name"]);
  }*/
  void _openQrScanner(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: MobileScanner(
            controller: MobileScannerController(
              facing: CameraFacing.back,
              detectionSpeed: DetectionSpeed.normal,
            ),
            onDetect: (capture) {
              Navigator.of(context).pop(); // ferme la caméra
              _onQrDetected(capture); // appel de ta fonction existante
            },
          ),
        ),
      );
    },
  );
}

Widget _buildProductTab() {
  return SingleChildScrollView(
    child: Column(
      children: [
        ListView.builder(
          itemCount: products.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (_, index) {
            final p = products[index];
            return ListTile(
              title: Text(p["name"]),
              subtitle: Text(
                "Prix: ${(p["price"] / BigInt.from(10).pow(6).toInt()).toStringAsFixed(2)} USDT",
              ),
            );
          },
        ),
        Divider(),
        Text("Scanner un QR Code pour payer", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        ElevatedButton.icon(
          icon: Icon(Icons.qr_code_scanner),
          label: Text("Scanner QR Code"),
		    onPressed: () async {
                await askCameraPermission();
                setState(() {
                  showScanner = true;
                });
              },
        ),
		if (showScanner)
              SizedBox(
                height: 300,
                child: MobileScanner(
                  onDetect: _onQrDetected,
                ),
              ),
      ],
    ),
  );
}




  Widget _buildOrdersTab() {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (_, index) {
        final o = orders[index];
        return ListTile(
          title: Text("🛒 ${o[0]}"),
          subtitle: Text("Client: ${o[2]} | Prix: ${(o[1] / BigInt.from(10).pow(6)).toStringAsFixed(2)} USDT"),
          //trailing: Text("🧾 ${o[3]}"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [_buildProductTab(), _buildOrdersTab()];
    return Scaffold(
      appBar: AppBar(
        title: Text("Solde: ${(balance / BigInt.from(10).pow(18)).toStringAsFixed(2)} USDT"),
       /* actions: [
          IconButton(onPressed: _scanQR, icon: Icon(Icons.qr_code_scanner)),
        ],*/
      ),
      body: tabs[_selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (i) {
          setState(() {
            _selectedTab = i;
            if (i == 1) _fetchOrders();
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Produits"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Mes Commandes"),
        ],
      ),
    );
  }
}

class QRScannerPage extends StatelessWidget {
  final scannerController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        controller: scannerController,
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          if (barcode.rawValue != null) {
            Navigator.pop(context, barcode.rawValue);
          }
        },
      ),
    );
  }
}
