// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

// TODO: Que la dosis guarde la localización geográfica de la aplicación para poder armar un mapa de densidad

/// @title Almacenamiento anónimo de la información relativa a la vacunación contra COVID
/// @author Martín Zavala
contract CertificadoVacunacion is AccessControl {

    struct Dosis {
        string sede;
        uint256 fecha;
        string marcaVacuna;
    }

    bool internal activo = true;

    bytes32 internal constant ROL_APLICADOR = keccak256("ROL_APLICADOR");
    bytes32 internal constant ROL_ADMIN = keccak256("ROL_ADMIN");

    mapping(address => Dosis[]) internal aplicacionesDosis;

    /// @notice Inicializa como administrador la dirección que hace deploy del contrato
    constructor() {
        _setRoleAdmin(ROL_ADMIN, ROL_ADMIN);
        _setRoleAdmin(ROL_APLICADOR, ROL_ADMIN);

        // el administrador será la cuenta que deploye el contrato
        _setupRole(ROL_ADMIN, msg.sender);
    }

    /// @notice Agregar una dirección con el rol de aplicador (quien registra la aplicación de una dosis)
    /// @param aplicador Dirección de la persona que puede registrar aplicaciones
    function agregarAplicador(address aplicador) public esActivo {
        grantRole(ROL_APLICADOR, aplicador);
    }

    /// @notice Elimina el rol de aplicador de una dirección
    /// @param aplicador Dirección de la persona a le que se le quita la posibilidad de registrar aplicaciones
    function eliminarAplicador(address aplicador) public esActivo {
        revokeRole(ROL_APLICADOR, aplicador);
    }

    /// @notice Registra la aplicación de una dosis a una persona. Para aplicar una dosis hay que ser aplicador.
    /// @param persona Dirección del paciente que está siendo vacunado
    /// @param _sede Nombre del lugar donde se aplica la dosis
    /// @param _fecha Timestamp del momento de aplicación
    /// @param _marcaVacuna Nombre de la marca de la vacuna aplicada
    /// @dev Emite el evento dosisAplicada
    function aplicarDosis(address persona, string memory _sede, uint256 _fecha, string memory _marcaVacuna) public esActivo esAplicador {
        Dosis memory dosis = Dosis(_sede, _fecha, _marcaVacuna);
        (aplicacionesDosis[persona]).push(Dosis(_sede, _fecha, _marcaVacuna));
        emit dosisAplicada(msg.sender, persona, dosis);
    }

    /// @notice Consulta la información de una dosis aplicada a una persona. Sólo lo puede hacer la misma persona vacunada.
    /// @return Sede de vacunación, timestamp y marca de la vacuna aplicada.
    function obtenerAplicacionDosis(address persona, uint8 nroDosis) public view esActivo esPropietarioCertificado(persona) returns(Dosis memory)  {
        return((aplicacionesDosis[persona])[nroDosis]);
    }

    /// @notice Consulta todas las dosis aplicadas a una persona. Sólo lo puede hacer la misma persona vacunada.
    /// @return Lista de: sede de vacunación, timestamp y marca de la vacuna aplicada.
    function obtenerAplicaciones(address persona) public view esActivo esPropietarioCertificado(persona) returns(Dosis[] memory)  {
        return(aplicacionesDosis[persona]);
    }

    /// @notice Evento que se dispara cada vez que una nueva dosis se aplica
    event dosisAplicada(address aplicador, address persona, Dosis dosis);

    /// @notice Evento que indica que el contrato se ha desactivado
    event contratoDesactivado(address admin);

    /// @notice Desactiva el contrato. Sólo puedo hacerlo el administrador. Una vez desactivado no puede activarse.
    function desactivarContrato() public esAdministrador {
        activo = false;
        emit contratoDesactivado(msg.sender);
    }

    /// @dev control de rol de aplicador
    modifier esAplicador {
        require(hasRole(ROL_APLICADOR, msg.sender), "solo permitido para aplicadores registrados");
        _;
    }

    /// @dev control de rol de paciente
    modifier esPropietarioCertificado(address persona) {
        require(msg.sender == persona, "solo permitido para el propietario del certificado");
        _;
    }

    /// @dev control de rol de administrador
    modifier esAdministrador {
        require(hasRole(ROL_ADMIN, msg.sender), "solo puede invocarlo el administrador del contrato");
        _;
    }

    /// @dev control si el contracto está desactivado
    modifier esActivo() {
        require(activo, "el contrato esta desactivado");
        _;
    }
}
