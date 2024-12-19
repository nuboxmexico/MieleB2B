class RequestDataMieleCore < ActiveRecord::Base

    # Metodo que permite encontrar las categorias(familias) de B2B de un producto proveniente de Miele Core 
    def self.find_asociated_families_in_b2b(core_taxons_from_product)

        families_to_assing = []
        unfinded_family_name = ''

        core_taxons_from_product.each_with_index do |taxon,index|
            if index == 0
                family = Family.find_by(name:taxon["name"],family_id:nil)
                
                if family
                    families_to_assing.push(family)
                else 
                    unfinded_family_name = taxon["name"]
                    break
                end 
            else   
                founded_family_child = families_to_assing[index-1].children.find_by(name:taxon['name'], depth:index) rescue nil

                if founded_family_child 
                    families_to_assing.push(founded_family_child)
                else 
                    unfinded_family_name = taxon["name"]
                    break
                end  
            end 
        end
        return {families_to_assing:families_to_assing,unfinded_family_name:unfinded_family_name}
    end 
    
    # Metodo que crea un producto sincronizando con Core en B2B
    def self.create_product_from_core_in_b2b(product_from_core,new_data,asociated_families,created_products,errors_report)

        if product_from_core["product_type"].blank?
            errors_report.push("NO se sincronizó el producto con SKU:#{product_from_core["tnr"]}, porque no tiene asignado el TIPO DE PRODUCTO (ejemplo: MDA,SDA,PAI)")
            return
        else 
            if product_from_core["product_type"] != "MDA" and product_from_core["product_type"] != "SDA" and product_from_core["product_type"] != "PAI" and product_from_core["product_type"] != "SERV" 
                errors_report.push(
                    "NO se actualizó el producto con SKU:#{product_from_core["tnr"]}, porque el TIPO DE PRODUCTO #{product_from_core["product_type"]} asignado es invalido, los valores validos son MDA, SDA, PAI o SERV")
                return
            end
        end

        created_product = Product.create(
            {
                sku: product_from_core["tnr"], 
                core_id: product_from_core["id"], 
                name: product_from_core["name"],
                description: product_from_core["description"],
                price: new_data[:new_price].to_i,
                stock: new_data[:new_stock].to_i,
                stock_break: new_data[:new_break_stock],
                product_type: product_from_core["product_type"]
            }
        )

        ## Asignar familias al producto en B2B
        if asociated_families[:unfinded_family_name].blank?
            asociated_families[:families_to_assing].each do |family|
                created_product.product_families << ProductFamily.create(family_id:family.id)
            end 
        else
            errors_report.push("Se sincronizo el producto con SKU:#{product_from_core["tnr"]}, pero se le asignó la categoria 'Sin categorizacion', porque no existe la categoria '#{asociated_families[:unfinded_family_name]}' en B2B")
            created_product.product_families << ProductFamily.create(family_id:Family.find_by(name:'Sin categorizacion').id)
        end

        ## Asignar SALE CHANNELS al Producto
        if product_from_core["projects_only"]
            product.sale_channels.destroy_all
            product.sale_channels << SaleChannel.find_by(name:'Proyectos')
        end 

        ## Crear Reporte Final 
        report_create_product = {
            tnr: product_from_core["tnr"], 
            nombre: product_from_core["name"],
            descripcion: product_from_core["description"],
            price: new_data[:new_price].to_i,
            stock: new_data[:new_stock].to_i,
        }
        created_products.push(report_create_product)
    end

    # Metodo que actualiza un producto sincronizando con Core en B2B
    def self.update_product_from_core_in_b2b(product_from_core,product,new_data,asociated_families,updated_products,errors_report)

        if product_from_core["product_type"].blank?
            errors_report.push("NO se actualizó el producto con SKU:#{product_from_core["tnr"]}, porque no tiene asignado el TIPO DE PRODUCTO (ejemplo: MDA,SDA,PAI)")
            return
        else 
            if product_from_core["product_type"] != "MDA" and product_from_core["product_type"] != "SDA" and product_from_core["product_type"] != "PAI" and product_from_core["product_type"] != "SERV"
                errors_report.push("NO se actualizó el producto con SKU:#{product_from_core["tnr"]},porque el TIPO DE PRODUCTO #{product_from_core["product_type"]} asignado es invalido, los valores validos son MDA, SDA, PAI o SERV")
                return
            end
        end

        old_stock = product.stock.to_i
        old_price = product.price.to_i

        if !product.bstock and !product.ean
            product.update(
                {
                    core_id: product_from_core["id"], 
                    name: product_from_core["name"],
                    description: product_from_core["description"],
                    price: new_data[:new_price].to_i,
                    stock: new_data[:new_stock].to_i,
                    stock_break: new_data[:new_break_stock],
                    product_type: product_from_core["product_type"]
                }
            )

            ## Crear Reporte Final 
            report_update_product = {
                tnr: product_from_core["tnr"],
                nombre: product_from_core["name"],
                descripcion: product_from_core["description"],
                stock: {
                    antiguo: old_stock,
                    nuevo: new_data[:new_stock]
                },
                precio: {
                    antiguo: old_price,
                    nuevo: new_data[:new_price]
                }
            }
            updated_products.push(report_update_product)  
        else 
            product.update(
                {
                    core_id: product_from_core["id"], 
                    name: product_from_core["name"],
                    description: product_from_core["description"],
                    price: new_data[:new_price].to_i,
                }
            )
        end 

        ## Asignar familias al producto en B2B
        product.product_families.destroy_all
        if asociated_families[:unfinded_family_name].blank?
            asociated_families[:families_to_assing].each do |family|
                product.product_families << ProductFamily.create(family_id:family.id)
            end 
        else
            errors_report.push("Se sincronizo el producto con SKU:#{product_from_core["tnr"]}, pero se le asignó la categoria 'Sin categorizacion', porque no existe la categoria '#{asociated_families[:unfinded_family_name]}' en B2B")
            product.product_families << ProductFamily.create(family_id:Family.find_by(name:'Sin categorizacion').id)
        end

        ## Asignar SALE CHANNELS al Producto
        if product_from_core["projects_only"]
            product.sale_channels.destroy_all
            product.sale_channels << SaleChannel.find_by(name:'Proyectos')
        end 
    end
    

    # Metodo que sincroniza los productos del B2B con los de Miele core
    def self.synchronizeProductsWithMieleCore
        begin 
            miele_core_tnrs = MieleCoreApi.getTnrProductsFromMieleCore("CL","B2B")["data"]
            miele_core_products_to_add_or_update = MieleCoreApi.find_product_by_tnr(miele_core_tnrs.join(","))["data"]

            if !miele_core_products_to_add_or_update.blank?

                errors_report = []
                created_products = []
                updated_products = []

                miele_core_products_to_add_or_update.each do |core_product| 

                    new_data = {
                        new_price: 0,
                        new_stock: 0,
                        new_break_stock: true
                    }
                    prices = core_product["product_prices"]
                    stocks = core_product["product_stocks"]

                    # Encontrar Precio CL
                    if !prices.empty?
                        prices.each do |price_obj|
                            if  price_obj["country_id"] == 2
                                new_data[:new_price] = price_obj["price"]
                                break
                            end
                        end
                    else
                        errors_report.push("No se ha podido sincronizar el precio del producto de SKU:'#{core_product["tnr"]}', porque no existe un precio asignado para el producto en Miele Core")
                    end

                    # Encontrar Stock CL                    
                    if !stocks.empty?
                        stocks.each do |stock_obj|
                            if  stock_obj["country_id"] == 2
                                new_data[:new_stock] = stock_obj["stock"]
                                new_data[:new_break_stock] = stock_obj["break"]
                                break
                            end
                        end
                    else
                        errors_report.push("No se ha podido sincronizar el stock del producto de SKU: '#{core_product["tnr"]}', porque no existe un stock asignado para el producto en Miele Core")
                    end

                    begin 
                        # Se Busca las categorias del producto provenientes de Miele Core y se revisa si es que son validad
                        core_product_taxons = core_product["taxons"]
                        if !core_product_taxons.blank?
                            asociated_families = self.find_asociated_families_in_b2b(core_product_taxons)   
                            b2b_product_records = Product.where(sku:core_product["tnr"]) rescue nil

                            if !b2b_product_records.empty?
                                ###################################################################
                                # Caso de que el producto Existe por lo que hay que actualizarlo
                                # Tambien se presenta el caso de varios productos bstock del mismo SKU(TNR), los cuales no se actualiza su stock encapsulandolo dentro del B2B
                                b2b_product_records.each_with_index do |product,i|
                                    self.update_product_from_core_in_b2b(core_product, product, new_data, asociated_families, updated_products, errors_report)
                                end
                                ##################################################################
                            else 
                                ##################################################################
                                # Caso de que el producto NO existe, por lo que hay que crearlo
                                self.create_product_from_core_in_b2b(core_product, new_data, asociated_families, created_products, errors_report)
                                ######################################################################
                            end
                        else 
                            errors_report.push("No se ha podido sincronizar el producto con SKU:#{core_product["tnr"]}, porque no tiene categorias asignadas en Miele Core") 
                        end
                    rescue Exception => e
                        errors_report.push(e.to_s)
                    end
                end

                if errors_report.empty?
                    return {
                        status:200,
                        fecha_reporte: Time.now.strftime("%H:%M %d-%m-%Y"),
                        message:"Todos los Productos fueron sincronizados con exito",
                        productos_creados:created_products,
                        products_actualizados:updated_products
                    }
                else 
                    if created_products.empty? and updated_products.empty?
                        return {status:400,message:"NO se sincronizó ningun producto",errors:errors_report}
                    else 
                        return {
                            status:400,
                            fecha_reporte: Time.now.strftime("%H:%M %d-%m-%Y"),
                            message:"Algunos productos se sincronizaron con exito, pero hubieron algunos con errores",
                            errors:errors_report,
                            productos_creados:created_products,
                            products_actualizados:updated_products,
                        }
                    end
                end
            end
            return {
                status:400,
                fecha_reporte: Time.now.strftime("%H:%M %d-%m-%Y"),
                message:"No se logró hacer request de los productos de miele core",
                errors:["En Miele Core no Existen productos para el B2B"]
            }
        rescue Exception => e
            return {
                status:400,
                fecha_reporte: Time.now.strftime("%H:%M %d-%m-%Y"),
                message:"No se logró hacer request de los productos a Miele core",
                errors:[e.to_s],
            }
        end
    end
end