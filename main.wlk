

// ---------------------------- PRODUCTORA ---------------------
object productora {
  var property impuesto = 200 // Impuesto fijado por la productora (configurable)
  const property bandas = []
  const property asistentes = []

  method agregarBanda(banda) {
    bandas.add(banda)
  }

  method agregarAsistente(asistente) {
    asistentes.add(asistente)
  }

  // Colección con todas las entradas vendidas en el sistema
  method todasLasEntradasVendidas() = asistentes.flatMap({ asistente => asistente.historialEntradas() })

  // Reporte de Ganancia total
  method gananciaTotal() {
    const recaudacionTotal = self.todasLasEntradasVendidas().sum({ entrada => entrada.precioAlPublico() })
    const totalPresupuestoBandas = bandas.sum({ banda => banda.presupuesto() })
    return recaudacionTotal - totalPresupuestoBandas
  }

  // Reporte de Cantidad de entradas vendidas
  method cantidadEntradasVendidas() = self.todasLasEntradasVendidas().size()

  method cantidadEntradasVendidasDe(banda) {
    return self.todasLasEntradasVendidas().count({ entrada => entrada.banda() == banda })
  }

  // Reporte de La banda más popular, que es la que vendió más entradas.
  method bandaMasPopular() {
    if (bandas.isEmpty()) {
      self.error("No hay bandas registradas en la productora.")
    }
    return bandas.max({ banda => self.cantidadEntradasVendidasDe(banda) })
  }

  // Bonificación a los asistentes VIP
  method bonificarAsistentesVip() {
    asistentes.forEach({ asistente => asistente.abono().bonificar() })
  }
}

// -------------------------- ENTRADAS --------------------------
class Entrada {
  const property banda
  const property fecha
  const precioBase = 1000

  method precioAlPublico() = precioBase + productora.impuesto()
}

// ---------------------------- ABONOS ---------------------------
object abonoFan {
  method montoAPagar(entrada) = entrada.precioAlPublico()
  method bonificar() {
    // El abono Fan no sufre cambios al bonificar
  }
}

class AbonoVip {
  var property porcentajeDescuento // Valor entre 0 y 1 (ej: 0.10 para 10%)

  method montoAPagar(entrada) {
    return entrada.precioAlPublico() * (1 - porcentajeDescuento)
  }

  method bonificar() {
    porcentajeDescuento += 0.01 // Aumenta el descuento en 1%
  }
}

// -------------------------- ASISTENTES -------------------------
class Asistente {
  var property abono
  var property dineroDisponible
  const property historialEntradas = []

  method comprarEntrada(entrada) {
    if (dineroDisponible <= 0) {
      self.error("No puede comprar entradas porque no posee un saldo positivo.")
    } else {
    const montoAPagar = abono.montoAPagar(entrada)
    dineroDisponible -= montoAPagar
    historialEntradas.add(entrada)
    }
  }

  method entradasDelAnioAnterior() {
    const anioAnterior = new Date().year() - 1
    return historialEntradas.filter({ entrada => entrada.fecha().year() == anioAnterior })
  }

  method nombresDeBandasCompradas() {
    return historialEntradas.map({ entrada => entrada.banda().nombre() }).asSet()
  }
}

// ----------------- BANDAS ----------------------
class Banda {
  const property nombre

  method canon() = 1000000
  method gastoExtra()
  method popularidad()

  method presupuesto() = self.canon() + self.gastoExtra()
}

class BandaRock inherits Banda {
  var property solosDeGuitarra

  override method gastoExtra() = 10000
  override method popularidad() = 100 * solosDeGuitarra
}

class BandaTrap inherits Banda {
  var property tieneHielo = false

  override method gastoExtra() = 0
  override method popularidad() = if (tieneHielo) 1000 else 0
  override method canon() = self.popularidad() * 1000000
}

class BandaIndie inherits Banda {
  const property instrumentos = []

  override method gastoExtra() = 500 * instrumentos.size()
  override method popularidad() = 3.14 * nombre.length()
}