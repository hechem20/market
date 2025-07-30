import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class CommandePage extends StatefulWidget {
  final EthereumAddress currentUserAddress; // Adresse du client connecté
  const CommandePage({Key? key, required this.currentUserAddress}) : super(key: key);

  @override
  State<CommandePage> createState() => _CommandePageState();
}

class _CommandePageState extends State<CommandePage> {
  late Web3Client _client;
  late DeployedContract _contract;
  List<Map<String, dynamic>> _orders = [];
  

  final String rpcUrl = "https://rpc-testnet.morphl2.io";
  final String privateKey = "0xcb19d6e37bbcdea36a35d8d0b23dbf51bbcdcf8f56beef118d1d7342bd6380bd";
  final String contractAddress = "0x52091e493E964ac257ddd7c6739505C1E58682a9";

  final EthereumAddress ownerAddress = EthereumAddress.fromHex("0xA02fbF2510341f24981DAB071B6aE707eE76651e"); // 🔑 Adresse du owner

  final String abiCode = '''[
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
] ''';

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    _client = Web3Client(rpcUrl, Client());
    final EthereumAddress contractAddr = EthereumAddress.fromHex(contractAddress);
    final contract = DeployedContract(ContractAbi.fromJson(abiCode, "OrderContract"), contractAddr);
    _contract = contract;
    await _getOrders();
  }

  Future<void> _getOrders() async {
    final getOrdersFunction = _contract.function("getAllOrders");
    final result = await _client.call(
      contract: _contract,
      function: getOrdersFunction,
      params: [],
    );

    List<Map<String, dynamic>> orders = [];

    for (var order in result[0]) {
      final address = order[4] as EthereumAddress;

      // 🔍 Si owner : tout voir | Si client : voir seulement ses commandes
      if (widget.currentUserAddress == ownerAddress || widget.currentUserAddress == address) {
        orders.add({
          'productName': order[0] as String,
          'price': (order[1] as BigInt).toDouble() / 1e6,
          'clientName': order[2] as String,
          'clientAddress': order[3] as String,
          'clientWallet': address.hex,
        });
      }
    }

    setState(() {
      _orders = orders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Commandes'),
        backgroundColor: Colors.teal,
      ),
      body: _orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text('🛒 ${order['productName']} - ${order['price']} USDT'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('👤 Client : ${order['clientName']}'),
                        Text('📍 Adresse : ${order['clientAddress']}'),
                        if (widget.currentUserAddress == ownerAddress)
                          Text('🧾 Wallet : ${order['clientWallet']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
