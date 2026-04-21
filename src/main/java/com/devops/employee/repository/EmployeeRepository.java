package com.devops.employee.repository;

import com.devops.employee.model.Employee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface EmployeeRepository extends JpaRepository<Employee, Long> {
    List<Employee> findByDepartment(String department);
    
    @Query("SELECT e FROM Employee e ORDER BY e.id ASC")
    List<Employee> findAllOrderById();
}
