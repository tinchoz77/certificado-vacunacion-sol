// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

struct Dosis {
    string sede;
    uint256 fecha;
    string marcaVacuna;
}

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
    function aplicarDosis(address persona, string memory _sede, uint256 _fecha, string memory _marcaVacuna) public esVacunador {
        (aplicacionesDosis[persona]).push(Dosis(_sede, _fecha, _marcaVacuna));
    }

    // para consultar la información de las dosis sólo lo puede hacer la misma persona vacunada
    function obtenerAplicacionDosis(address persona, uint8 nroDosis) public view esPropietarioCertificado(persona) returns(Dosis memory)  {
        return((aplicacionesDosis[persona])[nroDosis]);
    }

    function obtenerAplicaciones(address persona) public view esPropietarioCertificado(persona) returns(Dosis[] memory)  {
        return(aplicacionesDosis[persona]);
    }

    modifier esVacunador {
        require(hasRole(ROL_VACUNADOR, msg.sender), "solo permitido para vacunadores registrados");
        _;
    }

    modifier esPropietarioCertificado(address persona) {
        require(msg.sender == persona, "solo permitido para el propietario del certificado");
        _;
    }
}
