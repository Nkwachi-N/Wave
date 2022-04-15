import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web3/flutter_web3.dart';

class MetaMaskProvider extends ChangeNotifier {
  static const operatingChain = 4;

  String currentAddress = '';

  int currentChain = -1;

  bool get isEnabled => ethereum != null;

  bool get isInOperatingChain => currentChain == operatingChain;

  bool get isConnected => isEnabled && currentAddress.isNotEmpty;

//Ethereum address
  final String myAddress = "0x913171bAd2c80fe6aa38304DC2AC888aEC500298";


//strore the value of alpha and beta
  String? waves;



  Future<void> connect() async {
    if (isEnabled) {
      final accs = await ethereum!.requestAccount();
      if (accs.isNotEmpty) currentAddress = accs.first;

      currentChain = await ethereum!.getChainId();

      notifyListeners();
    }
  }

  clear() {
    currentAddress = '';
    currentChain = -1;
    notifyListeners();
  }

  init() async {
    if (isEnabled) {
      final accounts = await ethereum!.getAccounts();
      if (accounts.isNotEmpty) {
        currentAddress = accounts[0];
        currentChain = await ethereum!.getChainId();
        notifyListeners();

        getWave();
        ethereum!.onAccountsChanged((accounts) {
          clear();
        });
        ethereum!.onChainChanged((accounts) {
          clear();
        });
      }
    }
  }

  wave() async {
    String abiFile = await rootBundle.loadString("assets/contract.json");


    Contract contract = Contract('0x913171bAd2c80fe6aa38304DC2AC888aEC500298', jsonEncode(jsonDecode(abiFile)['abi']), provider!.getSigner());
    waves = 'calling contract';
    notifyListeners();

    final tx = await contract.call('wave');
    waves = 'transaction hash is ${tx.hash}';
    notifyListeners();
    await tx.wait();
    waves = 'getting waves';
    notifyListeners();

    final waveCount = await contract.call<BigInt>('getTotalWaves');
    waves = 'you have $waveCount';
    notifyListeners();


  }
  //
  getWave() async {

    String abiFile = await rootBundle.loadString("assets/contract.json");


    Contract contract = Contract('0x913171bAd2c80fe6aa38304DC2AC888aEC500298', jsonEncode(jsonDecode(abiFile)['abi']), provider!.getSigner());

    final waveCount = await contract.call<BigInt>('getTotalWaves');
    waves = '$waveCount on the blockchain!';
    notifyListeners();
  }
}
