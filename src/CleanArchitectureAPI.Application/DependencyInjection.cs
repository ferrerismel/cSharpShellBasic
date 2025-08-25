using Microsoft.Extensions.DependencyInjection;
using AutoMapper;
using FluentValidation;
using CleanArchitectureAPI.Application.Interfaces;
using CleanArchitectureAPI.Application.Services;
using CleanArchitectureAPI.Application.Mappings;
using CleanArchitectureAPI.Application.Validators;
using CleanArchitectureAPI.Application.DTOs;

namespace CleanArchitectureAPI.Application
{
    public static class DependencyInjection
    {
        public static IServiceCollection AddApplication(this IServiceCollection services)
        {
            // Configuración de AutoMapper
            services.AddAutoMapper(typeof(ProductMappingProfile).Assembly);

            // Configuración de FluentValidation
            services.AddValidatorsFromAssemblyContaining<CreateProductDtoValidator>();

            // Registro de servicios
            services.AddScoped<IProductService, ProductService>();

            return services;
        }
    }
}