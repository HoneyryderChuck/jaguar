require 'fileutils'
require 'certificate_authority'


module CreateCerts
  def delete_certs
    FileUtils.rm_rf(certs_dir)
  end

  def client_cert_path
    File.join(certs_dir, "client.crt")
  end

  def client_key_path
    File.join(certs_dir, "client.key")
  end

  def server_cert_path
    File.join(certs_dir, "server.crt")
  end

  def server_key_path
    File.join(certs_dir, "server.key")
  end

  def ca_cert_path
    File.join(certs_dir, "ca.crt")
  end

  def ca_key_path
    File.join(certs_dir, "ca.key")
  end

  def create_certs
    FileUtils.mkdir_p(certs_dir)
    
    ca = CertificateAuthority::Certificate.new
    
    ca.subject.common_name  = 'jaggyjag.com'
    ca.serial_number.number = 1
    ca.key_material.generate_key
    ca.signing_entity = true
    
    ca.sign! 'extensions' => { 'keyUsage' => { 'usage'  => %w(critical keyCertSign) } }
    
    File.write ca_cert_path, ca.to_pem
    File.write ca_key_path,  ca.key_material.private_key.to_pem
   

 
    server_cert = CertificateAuthority::Certificate.new
    server_cert.subject.common_name  = '127.0.0.1'
    server_cert.serial_number.number = 1
    server_cert.key_material.generate_key
    server_cert.parent = ca
    server_cert.sign!
    
    File.write server_cert_path, server_cert.to_pem
    File.write server_key_path,  server_cert.key_material.private_key.to_pem
    
   
 
    client_cert = CertificateAuthority::Certificate.new
    client_cert.subject.common_name  = '127.0.0.1'
    client_cert.serial_number.number = 1
    client_cert.key_material.generate_key
    client_cert.parent = ca
    client_cert.sign!
    
    File.write client_cert_path, client_cert.to_pem
    File.write client_key_path,  client_cert.key_material.private_key.to_pem
    

    # TODO
    #client_unsigned_cert = CertificateAuthority::Certificate.new
    #client_unsigned_cert.subject.common_name  = '127.0.0.1'
    #client_unsigned_cert.serial_number.number = 1
    #client_unsigned_cert.key_material.generate_key
    #client_unsigned_cert.sign!
    #
    #client_unsigned_cert_path = File.join(certs_dir, 'client.unsigned.crt')
    #client_unsigned_key_path  = File.join(certs_dir, 'client.unsigned.key')
    #
    #File.write client_unsigned_cert_path, client_unsigned_cert.to_pem
    #File.write client_unsigned_key_path,  client_unsigned_cert.key_material.private_key.to_pem
  end
end
