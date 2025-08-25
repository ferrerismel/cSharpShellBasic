using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using CleanArchitectureAPI.Application.DTOs;
using CleanArchitectureAPI.Application.Interfaces;
using System.Security.Claims;

namespace CleanArchitectureAPI.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ProductsController : ControllerBase
    {
        private readonly IProductService _productService;

        public ProductsController(IProductService productService)
        {
            _productService = productService;
        }

        /// <summary>
        /// Obtiene todos los productos
        /// </summary>
        /// <returns>Lista de productos</returns>
        /// <response code="200">Retorna la lista de productos</response>
        /// <response code="401">No autorizado</response>
        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<ProductDto>), 200)]
        [ProducesResponseType(401)]
        public async Task<ActionResult<IEnumerable<ProductDto>>> GetProducts()
        {
            var products = await _productService.GetAllAsync();
            return Ok(products);
        }

        /// <summary>
        /// Obtiene un producto por su ID
        /// </summary>
        /// <param name="id">ID del producto</param>
        /// <returns>Producto encontrado</returns>
        /// <response code="200">Retorna el producto</response>
        /// <response code="404">Producto no encontrado</response>
        /// <response code="401">No autorizado</response>
        [HttpGet("{id}")]
        [ProducesResponseType(typeof(ProductDto), 200)]
        [ProducesResponseType(404)]
        [ProducesResponseType(401)]
        public async Task<ActionResult<ProductDto>> GetProduct(int id)
        {
            var product = await _productService.GetByIdAsync(id);
            if (product == null)
                return NotFound();

            return Ok(product);
        }

        /// <summary>
        /// Obtiene productos por categoría
        /// </summary>
        /// <param name="category">Categoría de los productos</param>
        /// <returns>Lista de productos de la categoría</returns>
        /// <response code="200">Retorna la lista de productos</response>
        /// <response code="401">No autorizado</response>
        [HttpGet("category/{category}")]
        [ProducesResponseType(typeof(IEnumerable<ProductDto>), 200)]
        [ProducesResponseType(401)]
        public async Task<ActionResult<IEnumerable<ProductDto>>> GetProductsByCategory(string category)
        {
            var products = await _productService.GetByCategoryAsync(category);
            return Ok(products);
        }

        /// <summary>
        /// Crea un nuevo producto
        /// </summary>
        /// <param name="createDto">Datos del producto a crear</param>
        /// <returns>Producto creado</returns>
        /// <response code="201">Producto creado exitosamente</response>
        /// <response code="400">Datos inválidos</response>
        /// <response code="401">No autorizado</response>
        [HttpPost]
        [Authorize(Roles = "Admin,Manager")]
        [ProducesResponseType(typeof(ProductDto), 201)]
        [ProducesResponseType(400)]
        [ProducesResponseType(401)]
        public async Task<ActionResult<ProductDto>> CreateProduct(CreateProductDto createDto)
        {
            var currentUser = User.FindFirst(ClaimTypes.Name)?.Value ?? "System";
            var product = await _productService.CreateAsync(createDto, currentUser);
            
            return CreatedAtAction(nameof(GetProduct), new { id = product.Id }, product);
        }

        /// <summary>
        /// Actualiza un producto existente
        /// </summary>
        /// <param name="id">ID del producto</param>
        /// <param name="updateDto">Datos actualizados del producto</param>
        /// <returns>Producto actualizado</returns>
        /// <response code="200">Producto actualizado exitosamente</response>
        /// <response code="400">Datos inválidos</response>
        /// <response code="404">Producto no encontrado</response>
        /// <response code="401">No autorizado</response>
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin,Manager")]
        [ProducesResponseType(typeof(ProductDto), 200)]
        [ProducesResponseType(400)]
        [ProducesResponseType(404)]
        [ProducesResponseType(401)]
        public async Task<ActionResult<ProductDto>> UpdateProduct(int id, UpdateProductDto updateDto)
        {
            var currentUser = User.FindFirst(ClaimTypes.Name)?.Value ?? "System";
            var product = await _productService.UpdateAsync(id, updateDto, currentUser);
            
            return Ok(product);
        }

        /// <summary>
        /// Elimina un producto
        /// </summary>
        /// <param name="id">ID del producto</param>
        /// <returns>Sin contenido</returns>
        /// <response code="204">Producto eliminado exitosamente</response>
        /// <response code="404">Producto no encontrado</response>
        /// <response code="401">No autorizado</response>
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(204)]
        [ProducesResponseType(404)]
        [ProducesResponseType(401)]
        public async Task<IActionResult> DeleteProduct(int id)
        {
            await _productService.DeleteAsync(id);
            return NoContent();
        }
    }
}