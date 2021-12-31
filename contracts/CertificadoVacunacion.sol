// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Dosis.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract CertificadoVacunacion is AccessControl {

    bytes32 internal constant ROL_VACUNADOR = keccak256("ROL_VACUNADOR");
    bytes32 internal constant ROL_ADMIN = keccak256("ROL_ADMIN");

    mapping(address => Dosis[]) internal aplicacionesDosis;

    constructor() {
        _setRoleAdmin(ROL_ADMIN, ROL_ADMIN);
        _setRoleAdmin(ROL_VACUNADOR, ROL_ADMIN);

        // el administrador será la cuenta que deploye el contrato
        _setupRole(ROL_ADMIN, msg.sender);
        
    }

    function agregarVacunador(address vacunador) public {
        grantRole(ROL_VACUNADOR, vacunador);
    }

    function eliminarVacunador(address vacunador) public {
        revokeRole(ROL_VACUNADOR, vacunador);
    }

    // para aplicar una dosis hay que ser vacunador
    function aplicarDosis(string memory _sede, uint256 _fecha, string memory _marcaVacuna) public esVacunador {
        (aplicacionesDosis[msg.sender]).push(Dosis(_sede, _fecha, _marcaVacuna));
    }

    function obtenerAplicacionDosis(address persona, uint8 nroDosis) public view returns(Dosis memory) {
        return((aplicacionesDosis[persona])[nroDosis]);
    }

    function obtenerAplicaciones(address persona) public view returns(Dosis[] memory) {
        return(aplicacionesDosis[persona]);
    }

    modifier esVacunador {
        require(hasRole(ROL_VACUNADOR, msg.sender));
        _;
    }

}
