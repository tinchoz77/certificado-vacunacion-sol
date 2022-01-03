// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract CertificadoVacunacion is AccessControl {

    struct Dosis {
        string sede;
        uint256 fecha;
        string marcaVacuna;
    }

    bytes32 internal constant ROL_APLICADOR = keccak256("ROL_APLICADOR");
    bytes32 internal constant ROL_ADMIN = keccak256("ROL_ADMIN");

    mapping(address => Dosis[]) internal aplicacionesDosis;

    constructor() {
        _setRoleAdmin(ROL_ADMIN, ROL_ADMIN);
        _setRoleAdmin(ROL_APLICADOR, ROL_ADMIN);

        // el administrador será la cuenta que deploye el contrato
        _setupRole(ROL_ADMIN, msg.sender);
    }

    function agregarAplicador(address aplicador) public {
        grantRole(ROL_APLICADOR, aplicador);
    }

    function eliminarAplicador(address aplicador) public {
        revokeRole(ROL_APLICADOR, aplicador);
    }

    // para aplicar una dosis hay que ser aplicador
    function aplicarDosis(address persona, string memory _sede, uint256 _fecha, string memory _marcaVacuna) public esAplicador {
        (aplicacionesDosis[persona]).push(Dosis(_sede, _fecha, _marcaVacuna));
    }

    // para consultar la información de las dosis sólo lo puede hacer la misma persona vacunada
    function obtenerAplicacionDosis(address persona, uint8 nroDosis) public view esPropietarioCertificado(persona) returns(Dosis memory)  {
        return((aplicacionesDosis[persona])[nroDosis]);
    }

    function obtenerAplicaciones(address persona) public view esPropietarioCertificado(persona) returns(Dosis[] memory)  {
        return(aplicacionesDosis[persona]);
    }

    modifier esAplicador {
        require(hasRole(ROL_APLICADOR, msg.sender), "solo permitido para aplicadores registrados");
        _;
    }

    modifier esPropietarioCertificado(address persona) {
        require(msg.sender == persona, "solo permitido para el propietario del certificado");
        _;
    }
}
