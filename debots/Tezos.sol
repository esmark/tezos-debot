pragma ton-solidity >=0.57.3;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "./interfaces/Debot.sol";
import "./interfaces/AddressInput/AddressInput.sol";
import "./interfaces/Menu/Menu.sol";
import "./interfaces/Network/Network.sol";
import "./interfaces/Terminal/Terminal.sol";
import "./interfaces/UserInfo/UserInfo.sol";


contract TezosContract is Debot {
    bytes m_icon;
    address m_wallet; //my Everscale address
    string tezos_address; //Tezos address
    string tezos_public_key; //Tezos public key
    string tezos_private_key; //Tezos private key

    mapping(uint256 => string) tezos_wallet;

    string constant DOMAIN = "https://rpc.hangzhounet.teztnets.xyz/"; //set test or main RPC domain

	// Modifier that allows to accept some external messages
	modifier checkPubkey {
		// Check that contract's public key is set
		require(msg.pubkey() != 0, 101);
		tvm.accept();
		_;
	}

    function setIcon(bytes icon) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_icon = icon;
    }

    function start() public override {
        mainMenu();
    }

    function mainMenu() private inline {
        Menu.select("Menu", "Select item", [
            MenuItem("Address", "Input Tezos address", tvm.functionId(menuAddress)),
            MenuItem("Balance", "Check balance XTZ", tvm.functionId(menuBalance)),
            MenuItem("Send", "Send transaction to the address", tvm.functionId(menuSend))
        ]);
    }

    function menuAddress() public {
        //AddressInput.get(tvm.functionId(setTezosAddress), "Enter Tezos address:");
        if (tezos_address != "") {
            Terminal.print(0, format("Tezos address is {}. Reset it?", tezos_address));
        }
        
        Terminal.input(tvm.functionId(setTezosAddress), "Enter Tezos address", false);
    }

    function menuBalance() public {

        if (tezos_address == "") {
            Terminal.input(tvm.functionId(setTezosAddress), "Firstly enter Tezos address", false);
        } 
        else {
            string[] headers;
            string url = DOMAIN + "chains/main/blocks/head/context/contracts/";
            url += tezos_address; //url += "tz1aWXP237BLwNHJcCD4b3DutCevhqq2T1Z9";
            url += "/balance";

            Network.get(tvm.functionId(setResponse), url, headers);
        }
    }

    function menuSend() public {

        if (tezos_address == "") {
            Terminal.input(tvm.functionId(setTezosAddress), "Firstly enter Tezos address", false);
        }
        else {
            string[] headers;
            string url = DOMAIN + "chains/main/blocks/head/context/contracts/";
            url += tezos_address;
            //url += "/balance";
            
            // TODO: continue here
            //headers.push("Content-Type: application/x-www-form-urlencoded");
            //Network.get(tvm.functionId(setResponse), url, headers);
        } 
    }

    function setTezosWallet(string value) public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        tezos_address = value;
    }

    function setTezosMapping(string value) public checkPubkey {
        //require(msg.pubkey() == tvm.pubkey(), 100);
        uint256 tvm_pubkey = tvm.pubkey();
        tvm.accept();
        tezos_wallet[tvm_pubkey] = value;
    }

    function setTezosAddress(string value) public {
        //require(msg.pubkey() == tvm.pubkey(), 100);
        require(value != "", 102);
        //tvm.accept();

        tezos_address = value;
        //tezos_wallet[value] = tezos_address;

        // TODO: verify correct address format
        Terminal.print(tvm.functionId(getTezosAddress), format("Tezos address: {}", tezos_address));
        
        mainMenu();
    }

    function getTezosAddress() public view returns (string wallet) {
        wallet = tezos_address;
    }

    function getTezosMapping() public view returns (string wallet) {
        uint256 tvm_pubkey = tvm.pubkey();
        wallet = tezos_wallet[tvm_pubkey];
    }

    function getTechInfo() public view returns (uint256 msg_pubkey, uint256 tvm_pubkey) {

        msg_pubkey = msg.pubkey();
        //Terminal.print(0, format("msg.pubkey: {}", msg_pubkey));
        tvm_pubkey = tvm.pubkey();
        //Terminal.print(0, format("tvm.pubkey: {}", tvm_pubkey));

    }

    function setResponse(int32 statusCode, string[] retHeaders, string content) public {
        require(statusCode == 200, 101);
        // TODO: analyze headers.
        /* for (string hdr: retHeaders) {
            Terminal.print(0, hdr);
        } */
        // TODO: deserialize content from json to structure using Json interface.
        Terminal.print(0, format("Balance, nXTZ: {}", content));

        mainMenu();
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ AddressInput.ID, Menu.ID, Network.ID, UserInfo.ID, Terminal.ID];
    }

    function getDebotInfo() public functionID(0xDEB) view override returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon) {
        name = "Tezos Wallet DeBot";
        version = "0.0.3";
        publisher = "Equity philosophers";
        key = "Tezos Wallet DeBot";
        author = "Equity philosophers";
        support = address(0);
        hello = "Please select a Menu Item.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }
}