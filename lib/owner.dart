import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:gateway/commande.dart';
class VendorPage extends StatefulWidget {
  const VendorPage({super.key});

  @override
  State<VendorPage> createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage> {
  late Web3Client ethClient;
 // final String rpcUrl = 'https://rpc-testnet.morphl2.io'; // Morph testnet RPC
    final String rpcUrl = "http://10.0.2.2:7545";

  final String privateKey = '0xcb19d6e37bbcdea36a35d8d0b23dbf51bbcdcf8f56beef118d1d7342bd6380bd';
  final String contractAddress = '0xC8F61a9EfD59833EaFf89f25C2f53187Be1ef06C';
  final String abi = '''[
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
]'''; // Remplacer par ABI réelle

  List<Map<String, dynamic>> productList = [];
  int totalBenefit = 0;

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final benefitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ethClient = Web3Client(rpcUrl, Client());
    loadProducts();
  }

  Future<DeployedContract> loadContract() async {
    final contract = DeployedContract(
      ContractAbi.fromJson(abi, "VendorProductManager"),
      EthereumAddress.fromHex(contractAddress),
    );
    return contract;
  }

  Future<void> loadProducts() async {
    final contract = await loadContract();
    final productCountFunction = contract.function('nextId');
    final result = await ethClient.call(
      contract: contract,
      function: productCountFunction,
      params: [],
    );
    int count = result[0].toInt();

    List<Map<String, dynamic>> loaded = [];
    for (int i = 1; i < count; i++) {
      final func = contract.function('products');
      final data = await ethClient.call(
        contract: contract,
        function: func,
        params: [BigInt.from(i)],
      );
      if (data[6]) {
        loaded.add({
          "id": data[0].toInt(),
          "name": data[1],
          "price": data[2].toInt(),
          "benefit": data[3].toInt(),
        });
      }
    }

    final totalFunc = contract.function('getTotalBenefit');
    final benefitResult = await ethClient.call(
      contract: contract,
      function: totalFunc,
      params: [],
    );

    setState(() {
      productList = loaded;
      totalBenefit = benefitResult[0].toInt();
    });
  }
Future<void> _updateProduct(int id, String name, int price, int benefit) async {
  try {
    final credentials = await ethClient.credentialsFromPrivateKey(privateKey);
	final contract = await loadContract();
	final updateProduct = contract.function("updateProduct");
    await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: updateProduct,
        parameters: [
          BigInt.from(id),
          name,
          BigInt.from(price),
          BigInt.from(benefit),
        ],
        maxGas: 200000,
      ),
      chainId: 1337, // ou ton chainId ex: 1337 pour Ganache
    );
    print("Produit mis à jour !");
    //await _fetchProducts(); // rafraîchir la liste
  } catch (e) {
    print("Erreur update: $e");
  }
}
Future<void> _deleteProduct(int id) async {
  try {
    final credentials = await ethClient.credentialsFromPrivateKey(privateKey);
	final contract = await loadContract();
   final deleteProduct = contract.function("deleteProduct");
    await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: deleteProduct,
        parameters: [BigInt.from(id)],
        maxGas: 150000,
      ),
      chainId: 1337,
    );
    print("Produit supprimé !");
   // await _fetchProducts(); // rafraîchir la liste
  } catch (e) {
    print("Erreur delete: $e");
  }
}
void _showUpdateDialog(Map<String, dynamic> product) {
  final nameCtrl = TextEditingController(text: product['name']);
  final priceCtrl = TextEditingController(text: product['price'].toString());
  final benefitCtrl = TextEditingController(text: product['benefit'].toString());

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Modifier Produit"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Nom")),
          TextField(controller: priceCtrl, decoration: InputDecoration(labelText: "Prix")),
          TextField(controller: benefitCtrl, decoration: InputDecoration(labelText: "Bénéfice")),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _updateProduct(
              product['id'],
              nameCtrl.text,
              int.parse(priceCtrl.text),
              int.parse(benefitCtrl.text),
            );
          },
          child: Text("Enregistrer"),
        ),
      ],
    ),
  );
}

  Future<void> addProduct(String name, int price, int benefit ) async {
    final contract = await loadContract();
    final function = contract.function('addProduct');
    final credentials = EthPrivateKey.fromHex(privateKey);
    final String qrCodeHash = "pay:$name"; 
    await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [name, BigInt.from(price), BigInt.from(benefit),qrCodeHash],
        maxGas: 500000,
      ),
      chainId:1337 , // Morph Testnet
    );
    await loadProducts();
  }

  Widget buildQR(String data) {
    return QrImageView(
      data: data,
      size: 100,
      version: QrVersions.auto,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("🛒 Vendor Page")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text("📈 Total bénéfice: ${totalBenefit / 1e6} USDT", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Nom produit")),
            TextField(controller: priceController, decoration: InputDecoration(labelText: "Prix (en USDT)")),
            TextField(controller: benefitController, decoration: InputDecoration(labelText: "Bénéfice")),
            ElevatedButton(
              onPressed: () async {
                await addProduct(
                  nameController.text,
                  (double.parse(priceController.text) * 1e6).toInt(),
                  (double.parse(benefitController.text) * 1e6).toInt(),
                );
              },
              child: Text("Ajouter produit"),
            ),
            SizedBox(height: 20),
            ...productList.map((product) {
              return Card(
                child: ListTile(
                  title: Text(product['name']),
                  subtitle: Text("Prix: ${product['price'] / 1e6} USDT, Bénéfice: ${product['benefit'] / 1e6} USDT "),
                   
                  trailing: Row(
        mainAxisSize: MainAxisSize.min,
		
        children: [
          GestureDetector(
  onTap: () {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("QR Code Agrandi"),
        content: SizedBox(
          width: 250,
          height: 250,
          child: buildQR("pay:${product['id']}"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Fermer"),
          ),
        ],
      ),
    );
  },
  child: SizedBox(
    width: 100,
    height: 100,
    child: buildQR("pay:${product['id']}"),
  ),
),

          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              _showUpdateDialog(product);
            },
          ),
          IconButton( 
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _deleteProduct(product['id']);
            },
          ),
        ],
      ),
	  
    ),
  );
      
            }).toList(),
          ],
        ),
      ),
    bottomNavigationBar: BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            icon: Icon(Icons.home),
            label: Text("Accueil"),
            onPressed: () {
             
            },
          ),
          TextButton.icon(
            icon: Icon(Icons.shopping_cart),
            label: Text("Commandes"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommandePage(
                    currentUserAddress: EthereumAddress.fromHex("0xA02fbF2510341f24981DAB071B6aE707eE76651e"),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );

  }
  
}
