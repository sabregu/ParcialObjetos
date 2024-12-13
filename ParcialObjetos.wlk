//PIZZAS    
class PizzaGrande{
    var property ingredientes
    const property porciones

    method tieneEsteIngrediente(ingrediente) = ingredientes.contains(ingrediente)
    method agregarTodosIngredientes(nuevosIngredientes) = nuevosIngredientes.all{nuevoIngrediente => ingredientes.agregarIngrediente(nuevoIngrediente)}
    method agregarIngrediente(ingrediente) = ingredientes.add(ingrediente)
    method precio() = ingredientes.sum{ingrediente => ingrediente.size()} * 100
    method mezclarCon(pizza) = self.agregarTodosIngredientes(pizza.ingredientes())
}

class PizzaChica inherits PizzaGrande(){
    override method porciones() = super()/2

    override method precio() = super()*3/4
}

class PizzaCompuesta{
    var property pizzasComponentes
    const property porciones //Maximo de pizzas que la pueden componer

    method tieneEsteIngrediente(ingrediente) = pizzasComponentes.any{pizza => pizza.tieneEsteIngrediente(ingrediente)}
    method mezclarCon(pizza) = self.agregarTodosIngredientes(pizza.ingredientes())
    method agregarTodosIngredientes(nuevosIngredientes) = pizzasComponentes.all{pizza => pizza.agregarTodosIngredientes(nuevosIngredientes)}
    method agregarIngrediente(ingrediente) = pizzasComponentes.all{pizza => pizza.agregarIngrediente(ingrediente)}
    method esvalida() = porciones >= pizzasComponentes.size() and pizzasComponentes.all{pizza => porciones <= pizza.porciones()}
    method precio() = pizzasComponentes.max{pizza => pizza.precio()}.precio()
}

// PIZZERIAS
class Pizzeria{
    const property costoBase
    const property factorChetez
    const property tipoPizzeria

    method precioFinalPizza(pizza) = (pizza.precio()+costoBase)*factorChetez.valor()
    method precioFinalPedido(pedido) = (pedido.sum{pizza => pizza.precio()}+costoBase)*factorChetez.valor()
    method realizarPedido(cliente,pedido){
        const loEntregado = self.loEntregado(pedido)
        const entregar = new Entrega(pedido = pedido,precioPedido = self.precioFinalPedido(pedido),aEntregar = loEntregado,precioFinalPedido = self.precioFinalPedido(loEntregado))
    
        cliente.recibirEntrega(entregar)
    }
    method loEntregado(pedido) = tipoPizzeria.modificacion(pedido)
}

class PizzeriaTipoIngredienteExtra{
    const property ingrediente

    method modificacion(pedido) = pedido.all{pizza => pizza.agregarIngrediente(ingrediente)}
}

class PizzeriaTipoResumen{
    const property cantPorciones

    method modificacion(pedido){
        const pizzaCompuesta = new PizzaCompuesta(pizzasComponentes = pedido,porciones = cantPorciones)

        if(pizzaCompuesta.esvalida())return [pizzaCompuesta] else throw new MessageNotUnderstoodException(message = "La cantidad de pizzas superan a la cantidad de porciones")
    }
}

class PizzeriaTipoLaPreferida{
    const property pizzaPreferida

    method modificacion(pedido) = pedido.map{pizza => pizza.mesclarCon(pizzaPreferida)}
}

object pizzeriaTipoLaCombineta{
    method modificacion(pedido){
        const listaPizzasParejas = utils.createPairs(pedido)

        return listaPizzasParejas.all{pareja => pareja.x().mesclarCon(pareja.y())}
    }
}

object pizzeriaNormal{
    method modificacion(pedido) = pedido
}

//FACTOR CHETEZ
class FactorChetez{
    var property valor

    method calcularValor()
}

// PEDIDOS
class Pedido{
    const property pizzas
}

// Entregas
class Entrega{
    const property pedido //listaDePizzas
    var property precioPedido
    var property aEntregar = []
    var property precioFinalPedido

    method precioPedido(pizzeria) {precioPedido = pizzeria.precioFinalPedido(pedido)} 
    method aEntregar(pizzeria){aEntregar = pizzeria.loEntregado(pedido)}

}

// CLIENTES
class Cliente{
    var property humor
    var property tipoCliente

    method humor() = utils.max(1,utils.min(10,humor))

    method hacerPedido(pedido,pizzeria) = pizzeria.realizarPedido(self,pedido)

    method recibirEntrega(entrega,pedido){
        if(tipoCliente.estaConforme(entrega)){humor +=1} else {humor = humor-1}
    }
}

object clienteExigente{
    method estaConforme(entrega){
        const pizzasEntrega = entrega.aEntregar()
        const pizzasPedido = entrega.pedido().pizzas()

        pizzasEntrega.all{pizza => pizzasPedido.contains(pizza)}
    }
}

object clienteHumilde{
    method estaConforme(entrega) = entrega.precioFinalPedido() > entrega.precioPedido()
}

class ClienteManioso{
    var property ingredienteQueOdia

    method estaConforme(entrega) = entrega.aEntregar().all{pizza => !pizza.tieneEsteIngrediente(ingredienteQueOdia)}
}


// ------------ UTILS ------------
object utils {
  /* Example:
    const list = createPairs(["one", "two", "three"])
    list ==> Answers ["one" -> "two", "two" -> "three"]  
    
    list.get(0).x() ==> Answers "one"
    list.get(0).y() ==> Answers "two"
    list.get(1).x() ==> Answers "two"
    list.get(1).y() ==> Answers "three"
  */
    method createPairs(list) =
    (0..(list.size()-2)).map{ pos => new Pair(x = list.get(pos), y = list.get(pos+1)) }

    method min(a,b){if(a>b)return b else return a}
    method max(a,b){if(a>b)return a else return b}
}