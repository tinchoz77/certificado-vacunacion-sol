const Certificado = artifacts.require("CertificadoVacunacion");

module.exports = function (deployer) {
  deployer.deploy(Certificado);
};
