# SmartWallet - Partie 1

## exercice 1

L'exercice 1 est indiqué dans les commentaires de SmartWallet.sol

## exercice 2

L'exercice 2 est indiqué dans les commentaires de SmartWallet.sol

## exercice 3

Tout travail mérite salaire.
L'owner du smart contract récupérera désormais un pourcentage lorsque des utilisateurs veulent récupérer leurs fonds au moment du call de `withdraw` et `withdrawAmount`.

Ajouter un owner au smart contract qui sera défini au moment du déploiement (donc dans le constructeur).
Un pourcentage, (un simple chiffre), sera également passé au constructeur.
L'owner recevra (écriture comptable), ce pourcentage des fonds qui ont été récupérés. L'owner pourra récupérer ses gains quand il le souhaite en faisant appelle à la fonction `withdraw` ou `withdrawAmount`.
Donc un utilisateur récupérera ses fonds moins le pourcentage de l'owner.
N'hesitez pas à utiliser des variables temporaires pour trouver les différents montants, et si vous devez effectuer une division (pour le produit en croix par exemple), toujours effectuer cette division en dernière opération (pour éviter une perte, car pas de chiffre à virgule dans Ethereum).
En effet `10 / 6 * 3` est différent de `10 * 3 / 6`
N'oubliez pas d'ajouter un getter (une fonction `view`) pour récupérer le pourcentage actuel qui est défini dans le smart contract.

## exercice 4

Ajouter une fonction `setPercentage` que seul l'owner du smart contract peut appeler pour changer le pourcentage ponctionné sur les fonds qui sont récupérés par les utilisateurs.

## exercice 5

Ajouter une variable d'état privée `_gain` et son getter associé `gain()` pour garder une trace des revenus générés par la ponction d'un pourcentage depuis la création du smart contract.

## SmartWallet - Partie 2 (Exercices Solidity et Ethereum - Partie 1)

Cet exercice améliorera notre smart contract `SmartWallet` du cours.
Si vous n'avez pas encore de repository SmartWallet créez en un.
Les Améliorations à ajouter sont indiquées dans les commentaire du code suivant:
Il y a 4 améliorations à ajouter.
A vous de juger des bons check à effectuer via des `require` ou des `modifier`

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Pour remix il faut importer une url depuis un repository github
// Depuis un project Hardhat ou Truffle on utiliserait: import "@openzeppelin/ccontracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "./Ownable.sol";

contract SmartWallet is Ownable {
    // library usage
    using Address for address payable;

    // State variables
    mapping(address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => bool) private _vipMembers;
    uint256 private _tax;
    uint256 private _profit;
    uint256 private _totalProfit;

    // Events
    event Deposited(address indexed sender, uint256 amount);
    event Withdrew(address indexed recipient, uint256);
    event Transfered(address indexed sender, address indexed recipient, uint256 amount);
    event VipSet(address indexed account, bool status);
    // Exercice 2
    // Ajouter un event Approval qui sera emit des qu'un approval aura été autorisé
    // il faudra qu'on y retrouve comme information l'ower des fonds, le spender et la somme autorisée
    // à etre depensée.

    // constructor
    constructor(address owner_, uint256 tax_) Ownable(owner_) {
        require(tax_ >= 0 && tax_ <= 100, "SmartWallet: Invalid percentage");
        _tax = tax_;
    }

    // modifiers
    // Le modifier onlyOwner a été défini dans le smart contract Ownable

    // Function declarations below
    receive() external payable {
        _deposit(msg.sender, msg.value);
    }

    fallback() external {

    }

    function deposit() external payable {
        _deposit(msg.sender, msg.value);
    }

    function withdraw() public {
        uint256 amount = _balances[msg.sender];
        _withdraw(msg.sender, amount);
    }

    function withdrawAmount(uint256 amount) public {
        _withdraw(msg.sender, amount);
    }

    // Exerice 3:
    // Implémenter cette fonction pour que le msg.sender autorise spender à
    // dépenser en son nom l'equivalent de amount
    // il faudra manipuler pour cela le double mapping _allowances
    function approve(address spender, uint256 amount) public {
    }

    function transfer(address recipient, uint256 amount) public {
        require(_balances[msg.sender] > 0, "SmartWallet: can not transfer 0 ether");
        require(_balances[msg.sender] >= amount, "SmartWallet: Not enough Ether to transfer");
        require(recipient != address(0), "SmartWallet: transfer to the zero address");
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfered(msg.sender, recipient, amount);
    }

    // Exercice 4:
    // Implémenter cette fonction pour que le msg.sender puisse transférer des fonds "amount" depuis "from" vers "to"
    // Il faudra emettre un event Transfered si le transfer est effectué avec succès
    function transferFrom(address from, address to, uint256 amount) public {
        // ecriture dans un registre comptable
    }


    function withdrawProfit() public onlyOwner {
        require(_profit > 0, "SmartWallet: can not withdraw 0 ether");
        uint256 amount = _profit;
        _profit = 0;
        payable(msg.sender).sendValue(amount);
    }

    function setTax(uint256 tax_) public onlyOwner {
        require(tax_ >= 0 && tax_ <= 100, "SmartWallet: Invalid percentage");
        _tax = tax_;
    }

    function setVip(address account) public onlyOwner {
        _vipMembers[account] = !_vipMembers[account];
        emit VipSet(account, _vipMembers[account]);
    }


    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    // Exercice 1
    // Implementer cette fonction pour qu'elle nous retourne ce que spender peut
    // encore dépenser en tant owner_.
    function allowance(address owner_, address spender) public view returns (uint256) {

    }

    function total() public view returns (uint256) {
        return address(this).balance;
    }

    function tax() public view returns (uint256) {
        return _tax;
    }

    function profit() public view returns(uint256) {
        return _profit;
    }

    function totalProfit() public view returns(uint256) {
        return _totalProfit;
    }

    function isVipMember(address account) public view returns (bool) {
        return _vipMembers[account];
    }

    function _deposit(address sender, uint256 amount) private {
        _balances[sender] += amount;
        emit Deposited(sender, amount);
    }

    function _withdraw(address recipient, uint256 amount) private {
        require(_balances[recipient] > 0, "SmartWallet: can not withdraw 0 ether");
        require(_balances[recipient] >= amount, "SmartWallet: Not enough Ether");
        // version de john avec ternaire
        // uint256 fees = _vipMembers[recipient] ? 0 : _calculateFees(amount, _tax);
        uint256 fees = 0;
        if(_vipMembers[recipient] != true) {
            fees = _calculateFees(amount, _tax);
        }
        uint256 newAmount = amount - fees;
        _balances[recipient] -= amount;
        _profit += fees;
        _totalProfit += fees;
        payable(msg.sender).sendValue(newAmount);
        emit Withdrew(msg.sender, newAmount);
    }

    function _calculateFees(uint256 amount, uint256 tax_) private pure returns (uint256) {
        return amount * tax_ / 100;
    }
}
```