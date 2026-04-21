package com.devops.employee.service;

import com.devops.employee.model.Employee;
import com.devops.employee.repository.EmployeeRepository;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class EmployeeService {
    private final EmployeeRepository repository;
    
    public EmployeeService(EmployeeRepository repository) {
        this.repository = repository;
    }
    
    public List<Employee> getAllEmployees() {
        return repository.findAllOrderById();
    }
    
    public Employee getEmployee(Long id) {
        return repository.findById(id).orElse(null);
    }
    
    public Employee saveEmployee(Employee employee) {
        return repository.save(employee);
    }
    
    public void deleteEmployee(Long id) {
        repository.deleteById(id);
    }
    
    public List<Employee> getEmployeesByDepartment(String department) {
        return repository.findByDepartment(department);
    }
}
